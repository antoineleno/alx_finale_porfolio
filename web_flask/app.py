#!/usr/bin/python3
"""
APP module
"""

from flask import Flask, session
from flask import redirect, url_for
from auth import app_views_auth
from wishlist import app_views_wishlist
from home import app_views_home
from wishlist import app_views_sell
from wishlist import app_views_rent
from auth import app_views_message
from property import app_views_property
from action import app_views_action
from flask_cors import CORS
from flask_login import LoginManager
from models import storage
from models.user import User
from models.agent import Agent
from models.message import Message, RoomParticipants
from flask_login import current_user
from auth.forms import SignInForm, SignUpForm, ForgotPasswordForm
from models.usersubcription import UserSubcription
from flask_socketio import join_room, leave_room, SocketIO, emit
import os
import random
import re
from datetime import datetime


app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = 'static/uploads'

CORS(app, resources={r'/*': {'origins': '0.0.0.0'}})
app.secret_key = "a2cf8cf6ad37b0d8eb2b51846aee0e34"
socketio = SocketIO(app)

app.register_blueprint(app_views_auth)
app.register_blueprint(app_views_wishlist)
app.register_blueprint(app_views_rent)
app.register_blueprint(app_views_sell)
app.register_blueprint(app_views_message)
app.register_blueprint(app_views_home)
app.register_blueprint(app_views_property)
app.register_blueprint(app_views_action)

login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'app_views_auth.login_view'


@app.context_processor
def inject_user():
    """Inject all base variables"""
    image_directory = os.path.join(
        'auth', 'static', 'img', 'advertisements'
        )

    unread_message = 0
    admin_phone_number = ""
    admin_email = ""
    admin_address = ""
    is_subscribed = False
    image_filenames = [
        filename for filename in os.listdir(image_directory)
        if filename.startswith("adver_image") and
        os.path.isfile(os.path.join(image_directory, filename))
    ]
    all_agents = storage.get_object(Agent, all="yes")
    agents = []
    for agent in all_agents:
        agents.append({'name': agent.agent_name, 'image': agent.image_url})

    def extract_number(file):
        match = re.search(r"(\d+)", file)
        return int(match.group(1)) if match else 0

    image_filenames = sorted(image_filenames, key=extract_number)
    admin_object = storage.get_object(User, user_type="Admin")
    if admin_object is not None:
        admin_phone_number = admin_object.phone_number
        admin_email = admin_object.email
        admin_address = admin_object.address

    if current_user.is_authenticated:
        user_id = current_user.id
        user_subscription = storage.get_object(
            UserSubcription, user_email=current_user.email)
        is_subscribed = True if user_subscription is not None else False
        user = storage.get_object(User, id=user_id)
        all_user_room = user.roomparticipants
        all_ids = []
        for u_room in all_user_room:
            all_ids.append(u_room.room_id)

        for u_room_id in all_ids:
            message_count = storage.get_object(
                Message,
                count=True,
                room_id=u_room_id,
                read_status=False,
                user_id=('!=', current_user.id)  # Pass operator as a tuple
            )

            unread_message += message_count

    profile_path = "user.avif"
    if current_user.is_authenticated:
        file_names = os.listdir("auth/static/img/")
        extensions = [".png", ".jpg", ".jpeg", ".gif"]
        matching_files = [
            f for f in file_names
            if f.startswith(str(current_user.id)) and
            any(f.endswith(ext) for ext in extensions)
        ]

        if matching_files:
            profile_path = matching_files[0]
    sub_adver_images = os.listdir("static/uploads/")
    matching_images = [
        f for f in sub_adver_images
        if 'Main_image' in f
    ]
    random_int = random.randint(0, len(matching_images) - 1)
    sub_adver_image = matching_images[random_int]
    return {
        'user': current_user,
        'profile_path': profile_path,
        'sign_in_form': SignInForm(),
        'sign_up_form': SignUpForm(),
        'unread_message': unread_message,
        'admin_phone_number': admin_phone_number,
        'admin_address': admin_address,
        'admin_email': admin_email,
        'forgot_password_form': ForgotPasswordForm(),
        'is_subscribed': is_subscribed,
        'agents': agents,
        'sub_adver_image': sub_adver_image,
        'image_filenames': image_filenames
    }


@login_manager.user_loader
def load_user(id):
    """Load current user session"""
    return storage.get_object(User, id=id)


@app.teardown_appcontext
def teardown_db(exception):
    """Close the session"""
    try:
        storage.close()
    except Exception as e:
        print("this is the error from tear down {}".format(e))
        pass


@socketio.on("connect")
def connect(auth):
    """connect user to a room"""
    room = session.get("room_id")

    if not room:
        return
    join_room(room)
    print("One user has enter the room")


@socketio.on("disconnect")
def disconnect():
    """Disconnect user from a room"""
    room = session.get("room_id")
    leave_room(room)
    print("One user left the roof")


@socketio.on("sendMessageToRoom")
def handle_message(data):
    """Handle emiting messages to the frontend"""
    try:
        room = data.get('roomId')
        user_id = session.get("_user_id")
        if user_id is None:
            emit("error", {"message": "User not found"})
            return
        room_participants = storage.get_object(RoomParticipants,
                                               room_id=room,
                                               all=True)
        online_status = False
        for participant in room_participants:
            if participant.user_id != current_user.id:
                roommate_id = participant.user_id
                user = storage.get_object(User, id=roommate_id)
                u_online_status = user.is_online

        user = storage.get_object(User, id=user_id)
        name = user.first_name + " " + user.last_name if user else "Anonymous"

        message_text = data.get("data", {}).get("message", "").strip()
        if not message_text:
            emit("error", {"message": "No message content provided"})
            return

        content = {
            "name": name,
            "message": message_text
        }
        room_p = storage.get_object(RoomParticipants,
                                    user_id=roommate_id,
                                    room_id=room)
        if u_online_status is True and room_p.room_position is True:
            online_status = True
        room_p.updated_at = datetime.utcnow()
        room_p.save()
        new_message = Message(room_id=room,
                              user_id=user_id,
                              message=content["message"],
                              read_status=online_status)
        new_message.save()

        if room_p.room_position is True:
            emit("message", content, room=room, include_self=False)
        else:
            pass

    except KeyError as e:
        print(f"Error: Missing key {e}")
        emit("error", {"message": "Invalid message format"})


@app.route('/')
def home():
    return redirect(url_for('app_view_home.home'))


if __name__ == "__main__":
    socketio.run(app, debug=True)
