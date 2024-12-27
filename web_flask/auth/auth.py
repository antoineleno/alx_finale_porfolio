#!/usr/bin/python3
"""
AUTH module
"""

from flask import Blueprint, render_template, session
from flask import redirect, url_for, flash, request, jsonify
from models import storage
from models.user import User
from models.transaction import Transaction, Subcription
from models.property import Property
from models.message import Room, RoomParticipants, Message
from models.agent import Agent
from flask_login import login_user, login_required, logout_user, current_user
from sqlalchemy.exc import IntegrityError
from werkzeug.utils import secure_filename
from models.usersubcription import UserSubcription
from .forms import SignInForm, SignUpForm, ForgotPasswordForm
from auth import app_views_auth
import secrets
import string
from PIL import Image
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import datetime
import os
import re
from operator import attrgetter


auth = Blueprint('auth', __name__)


@app_views_auth.route('/login', methods=['GET', 'POST'])
def login_view():
    """Login function"""

    sign_in_form = SignInForm()

    if sign_in_form.validate_on_submit():
        email = sign_in_form.email.data
        password = sign_in_form.password.data
        user = storage.get_object(User, email=email)

        if user:
            if user.verify_password(password=password):
                message = "Successfully Logged In"
                login_user(user)
                flash(message, 'success')
                return redirect(url_for('app_view_home.home'))
            message = "Authentification failed : Password or email incorrect"
            flash(message, "error")
            return redirect(url_for('app_view_home.home'))
        else:
            message = "Account doesn't exist"
            flash(message, "error")
            return redirect(url_for('app_view_home.home'))


@login_required
@app_views_auth.route('/log_out', methods=['GET'])
def log_out():
    """User logout Function"""
    logout_user()
    return redirect(url_for('app_view_home.home'))


@app_views_auth.route('/sign_up', methods=['GET', 'POST'])
def sign_up():
    """Sing up function"""
    sign_up_form = SignUpForm()
    if sign_up_form.validate_on_submit():
        first_name = sign_up_form.first_name.data
        last_name = sign_up_form.last_name.data
        address = sign_up_form.address.data
        email = sign_up_form.email.data
        phone_number = sign_up_form.phone_number.data
        password = sign_up_form.password.data
        user_type = sign_up_form.user_type.data
        my_dict = {"first_name": first_name,
                   "last_name": last_name,
                   "email": email,
                   "phone_number": phone_number,
                   "password": password,
                   "user_type": user_type,
                   "address": address,
                   "profile_image": "user.avif"}

        new_instance = User()
        for key, value in my_dict.items():
            setattr(new_instance, key, value)
        try:
            new_instance.save()
            message = """Account successfully created"""
            flash(message, 'success')
            return redirect(url_for('app_view_home.home'))

        except IntegrityError as e:
            storage.close()
            message = """Account not created, Email already exist"""
            flash(message, 'error')
            return redirect(url_for('app_view_home.home'))
    else:
        message = """An error occur while creating your accound!"""
        flash(message, 'error')
        return redirect(url_for('app_view_home.home'))


@app_views_auth.route('/forgot_password', methods=['GET', 'POST'])
def forget_password():
    """"Forget password method"""
    forgot_password_form = ForgotPasswordForm()
    if forgot_password_form.validate_on_submit():
        email = forgot_password_form.email.data
        user = storage.get_object(User, email=email)
        if user:
            new_password = generate_password()
            user.password = new_password
            storage.save()

            send_email(email=email, html_file="email.html",
                       new_password=new_password, property_link=None)
            message = """A password reset message has been
            sent to your email address.
            """
            flash(message, "success")
            return redirect(url_for('app_view_home.home'))
        else:
            message = "There is no account associated with this email."
            flash(message, "error")
            return redirect(url_for('app_view_home.home'))


@app_views_auth.route('/base', methods=['GET', 'POST'])
def base():
    """Base function"""
    update_online_status(False)
    return render_template('base.html')


@login_required
@app_views_auth.route('/messages', methods=['GET'])
def get_messages():
    """Get all inbox converstaions"""
    update_online_status(False)
    user = storage.get_object(User, id=current_user.id)
    all_user_room = user.roomparticipants
    sorted_rooms = sorted(all_user_room, key=attrgetter('updated_at'),
                          reverse=True)
    all_room_ids = [p.room_id for p in sorted_rooms]
    messages_data = []

    try:
        for room_id in all_room_ids:
            content = {}
            room = storage.get_object(Room, id=room_id)
            all_room_participants = room.roomparticipants
            all_user_ids = [m.user_id for m in all_room_participants]
            contact_id = (
                all_user_ids[0]
                if all_user_ids[0] != current_user.id
                else all_user_ids[1]
                )

            contact_user = storage.get_object(User, id=contact_id)
            contact_name = """{} {}""".format(contact_user.first_name,
                                              contact_user.last_name)
            contact_image_url = contact_user.profile_image
            latest_message = storage.get_object(Message,
                                                all=None,
                                                order_by=(Message.created_at,
                                                          'desc'),
                                                limit=1, room_id=room_id)
            content['read_status'] = False
            if latest_message is not None:
                s = latest_message.user_id == current_user.id
                content['read_status'] = (True
                                          if s
                                          else latest_message.read_status
                                          )
            content['room_id'] = room_id
            content['contact_name'] = contact_name
            content['contact_image_url'] = (
                "/auth/static/img/"
                + contact_image_url
            )

            if latest_message:
                content['latest_message'] = (
                    latest_message.message[:35] + "..."
                    if len(latest_message.message) > 35
                    else latest_message.message
                    )

            else:
                content['latest_message'] = ""

            messages_data.append(content)

        return jsonify(messages_data)
    except Exception as e:
        print("this is the error from get messages {}".format(e))
        return jsonify(messages_data)


@login_required
@app_views_auth.route('/new_conversation', methods=['GET', 'POST'])
def new_conversation():
    """Create a new room for a user"""
    property_id = request.form.get('property_id')
    if current_user.is_authenticated:
        message_property = storage.get_object(Property, id=property_id)
        property_owner_id = message_property.user_id
        if property_owner_id != current_user.id:
            if request.method == "POST":
                show_modal = "yes"

                current_user_id = request.form.get('current_user_id')
                receiver_id = request.form.get('receiver_id')
                room_checking_1 = storage.get_object(RoomParticipants,
                                                     user_id=current_user_id,
                                                     property_id=property_id)
                room_checking_2 = storage.get_object(RoomParticipants,
                                                     user_id=receiver_id,
                                                     property_id=property_id)
                if room_checking_1 is not None and room_checking_2 is not None:
                    s = room_checking_1.room_id == room_checking_2.room_id
                    if room_checking_1 and room_checking_2 and s:
                        room_checking_1.updated_at = datetime.datetime.utcnow()
                        room_checking_2.updated_at = datetime.datetime.utcnow()
                        room_checking_1.save()
                        room_checking_2.save()
                        return redirect(url_for(
                            'app_view_property.property_onclick',
                            property_id=property_id,
                            show_modal=show_modal))
                else:
                    new_room = Room()
                    first_room_participant = RoomParticipants(
                        user_id=current_user_id,
                        property_id=property_id,
                        room_id=new_room.id)
                    second_room_participant = RoomParticipants(
                        user_id=receiver_id,
                        property_id=property_id,
                        room_id=new_room.id)
                    new_room.save()
                    first_room_participant.save()
                    second_room_participant.save()
                    message = Message(user_id=current_user_id,
                                      room_id=new_room.id,
                                      message="New conversation opened!")
                    message.save()
                    update_online_status(False)
                    return redirect(
                        url_for('app_view_property.property_onclick',
                                show_modal=show_modal,
                                property_id=property_id))
        else:
            message = """You are the owner of this property.
            You can't contact yourself."""
            flash(message, "error")
            return redirect(url_for('app_view_property.property_onclick',
                                    property_id=property_id))
    else:
        message = """You need to log in before contacting the listing agent!"""
        flash(message, "error")
        return redirect(url_for('app_view_property.property_onclick',
                                property_id=property_id))


@login_required
@app_views_auth.route('/messages/<room_id>', methods=['GET'])
def get_conversation(room_id):
    """Return messages for a specific conversation."""
    if current_user.is_authenticated:
        session.pop('room_id', None)
        session['room_id'] = room_id
        session['current_user'] = current_user.id

        update_online_status(True, room_id)
        all_messages = storage.get_object(Message, all="yes")
        room_messages = [
            chat
            for chat in all_messages
            if chat.room_id == room_id
            ]

        room_messages.sort(key=lambda chat: chat.created_at, reverse=False)

        room_participant = storage.get_object(RoomParticipants,
                                              room_id=room_id)
        if not room_participant:
            return jsonify({"error": "Room not found"}), 404

        property_id = room_participant.property_id
        room_property = storage.get_object(Property, id=property_id)
        property_name = room_property.title
        property_url = (
            "http://127.0.0.1:5000/" +
            url_for('app_view_property.property_onclick',
                    property_id=property_id)
        )

        my_conversation = {
            "property_name": property_name,
            "property_url": property_url,
            "messages": []
        }
        try:
            users = {user.id: user for user in storage.all(User).values()}
            for chat in room_messages:
                sender = users.get(chat.user_id, None)
                if not sender:
                    continue
                s_name = (
                    f"{sender.first_name} {sender.last_name}"
                    if chat.user_id != current_user.id
                    else "You"
                    )
                t_s = chat.created_at.strftime("%d/%m/%Y, %H:%M:%S")
                message_data = {
                    "sender_name": s_name,
                    "text": chat.message,
                    "timestamp": t_s,
                    "sender": chat.user_id != current_user.id
                }
                my_conversation["messages"].append(message_data)

            latest_message = storage.get_object(Message,
                                                all=None,
                                                order_by=(Message.created_at,
                                                          'desc'),
                                                limit=1, room_id=room_id)
            if latest_message.user_id != current_user.id:
                latest_message.read_status = True
                messages = storage.get_object(
                    cls=Message,
                    all=True,
                    room_id=room_id,
                    user_id=latest_message.user_id,
                    read_status=False
                )
                for message in messages:
                    message.read_status = True
                storage.save()
            return jsonify(my_conversation)
        except Exception as e:
            print("this is the error from get_conversation {}".format(e))
            return jsonify(my_conversation)
    else:
        return render_template('404.html')


@login_required
@app_views_auth.route('/subcribe_to_new_properties', methods=['GET', 'POST'])
def user_subription():
    """Subcribe to receive new update"""
    if current_user.is_authenticated:
        if request.method == "POST":
            subscription_action = request.form.get('subscription_action')
            if subscription_action == 'subscribe':
                new_subription = UserSubcription(user_email=current_user.email)
                new_subription.save()
                message = """Successfully subscribed! You will
                receive updates whenever a new property is listed."""
                flash(message, 'success')
                return redirect(url_for('app_view_home.home'))
            else:
                user_subription = storage.get_object(
                    UserSubcription, user_email=current_user.email)
                user_subription.delete()
                storage.save()
                message = """You have successfully unsubscribed.
                You will no longer receive updates about
                new property listings."""
                flash(message, 'success')
                return redirect(url_for('app_view_home.home'))
    else:
        message = """Please log in before subscribing"""
        flash(message, 'error')
        return redirect(url_for('app_view_home.home'))


@login_required
@app_views_auth.route('/profile', methods=['GET', 'POST'])
def profile():
    """Base function"""
    if current_user.is_authenticated:
        properties = storage.get_object(Property,
                                        user_id=current_user.id,
                                        all="yes")

        property_ids = [p.id for p in properties]

        if request.method == 'POST':
            user = storage.get_object(User, id=current_user.id)
            first_name = request.form.get('first_name')
            user.first_name = first_name
            last_name = request.form.get('last_name')
            user.last_name = last_name
            address = request.form.get('address')
            user.address = address
            phone_number = request.form.get('phone_number')
            user.phone_number = phone_number
            user_type = request.form.get('user_type')
            if user_type is not None:
                user.user_type = user_type
            email = request.form.get('email')
            user.email = email
            profile_file = request.files.get('profile_pic')
            if profile_file:
                _, file_extension = os.path.splitext(profile_file.filename)
                user_id = current_user.id
                filename = secure_filename(f"{user_id}{file_extension}")
                image_dirtory = 'auth/static/img'
                for file in os.listdir(image_dirtory):
                    img = (file.startswith(user_id) and
                           file != f"{user_id}"
                           f"{filename}")
                    if img:
                        os.remove(os.path.join(
                            image_dirtory, file))
                profile_file.save(os.path.join('auth', 'static', 'img',
                                               filename))
                user.profile_image = filename
            old_password = request.form.get('old_password')
            new_password = request.form.get('new_password')
            if old_password or new_password:
                if old_password and new_password:
                    if user.verify_password(password=old_password):
                        user.password = new_password
                        message = """Password successfully updated"""
                        e_type = "success"
                    else:
                        message = """Password not updated, old password
                        incorrect."""
                        e_type = "error"
                    flash(message, e_type)
                else:
                    message = """Password not updated, you should
                    provide both fields."""
                    flash(message, "error")
            storage.save()
            return redirect(url_for('app_views_auth.profile'))
        else:
            status = storage.get_object(Subcription, all='true')
            if len(status) == 0:
                s_status = "Suspended"
            else:
                s_status = status[0].status

            user = storage.get_object(User, id=current_user.id)
            first_name = user.first_name
            last_name = user.last_name
            full_name = first_name + " " + last_name
            phone_number = user.phone_number
            user_type = user.user_type
            email = user.email
            address = user.address

            return render_template('profile.html',
                                   full_name=full_name,
                                   first_name=first_name,
                                   last_name=last_name,
                                   phone_number=phone_number,
                                   user_type=user_type,
                                   email=email,
                                   address=address,
                                   property_ids=property_ids,
                                   s_status=s_status)
    else:
        return render_template('404.html')


@login_required
@app_views_auth.route('/evaluate-cost', methods=['POST'])
def evaluate_cost():
    """Evaluate payment cost"""
    data = request.get_json()
    property_id = data.get('property_id')
    all_subtriptions = storage.get_object(Transaction,
                                          supplier_id=current_user.id,
                                          all="yes")
    amount = 1000
    percentage = len(all_subtriptions)
    if percentage >= 100:
        percentage = 1000
    reduction = amount * (percentage / 100)
    monthly_cost = amount - reduction
    return jsonify({'monthly_cost': monthly_cost})


@login_required
@app_views_auth.route('/confirmation', methods=['POST', 'GET'])
def confirm_payement():
    """Confirm property payement
    send the request payment to orange moeny with
    the property id and supplier id"""

    property_id = request.args.get('property_id')
    amount = request.args.get('monthly_cost')
    supplier_id = current_user.id
    phone_number = current_user.phone_number
    message = """Your payment is being processed.
    You will receive a confirmation message once it is complete."""
    flash(message, "success")

    return redirect(url_for('app_views_auth.profile'))


@app_views_auth.route('/payment_confirmation_api', methods=['POST'])
def reveive_payment():
    """reveive payment confirmation"""
    data = request.get_json()
    if data:
        property_id = data.get('property_id')
        supplier_id = data.get('supplier_id')
        payment_status = data.get('payment_status')
        if payment_status == "Done":
            my_dict = {"property_id": property_id,
                       "supplier_id": supplier_id,
                       "payment_status": payment_status,
                       "duration": 30}
            try:
                m = "Data successfylly processed"
                old_subcription = storage.get_object(Transaction,
                                                     property_id=property_id,
                                                     supplier_id=supplier_id)
                if old_subcription is not None:
                    old_subcription.duration = old_subcription.duration + 30
                    storage.save()
                    return jsonify({"status": "succes",
                                    "message": m}), 200
                new_transaction = Transaction()
                for key, value in my_dict.items():
                    setattr(new_transaction, key, value)
                new_transaction.save()
                return jsonify({"status": "succes",
                                "message": m}), 200
            except Exception as e:
                return jsonify({"status": "error",
                                "message": "Data not processed"}), 422
        else:
            return
    else:
        return jsonify({"status": "error", "message": "No data passed"}), 422


@login_required
@app_views_auth.route('/property_subcription', methods=['GET'])
def property_subcription():
    """Property subcription"""
    property_attributes = []
    wishlist_type = ""

    if current_user.is_authenticated and current_user.user_type == "Supplier":
        user = storage.get_object(User, id=current_user.id)
        all_properties = user.properties

        for property in all_properties:
            duration = None
            subcrition = storage.get_object(Transaction,
                                            property_id=property.id,
                                            supplier_id=current_user.id)
            if subcrition is not None:
                duration = subcrition.duration
            values = {
                'id': property.id,
                'title': property.title,
                'duration': duration,
                'address': f"""{property.address}, {property.city},
                {property.country}""",
                'price': property.price,
                'area': property.area,
                'bedrooms': property.bedrooms,
                'bathrooms': property.bathrooms,
                'picture_link': storage.get_image(
                    property.id, "Main_image").image_url
            }
            property_attributes.append(values)

        return render_template('property_subcription.html',
                               property_attributes=property_attributes,
                               wishlist_type=wishlist_type)
    else:
        return render_template('404.html')


@login_required
@app_views_auth.route('/admin', methods=['GET'])
def admin_panel():
    """Admin control panel"""
    if current_user.is_authenticated and current_user.user_type == "Admin":
        user = storage.get_object(User, id=current_user.id)
        full_name = user.first_name + " " + user.last_name
        return render_template('control_panel.html', full_name=full_name)
    else:
        return render_template('404.html')


@login_required
@app_views_auth.route('/subcription', methods=['GET', 'POST'])
def manage_subcription():
    """Subcription control panel"""
    if current_user.is_authenticated and current_user.user_type == "Admin":
        if request.method == "POST":
            action = request.form.get('action')
            subcription = storage.get_object(Subcription, all="true")
            if len(subcription) == 0:
                new_instance = Subcription()
                setattr(new_instance, "status", action)
                new_instance.save()
            else:
                subcription[0].status = action
                storage.save()
            return redirect(url_for('app_views_auth.manage_subcription'))
        all_users = storage.get_object(User, user_type="Supplier", all="true")
        all_users.append(storage.get_object(User, user_type="Admin"))
        users = []
        s_status = storage.get_object(Subcription, all="true")
        if len(s_status) == 0:
            status = "Suspended"
        else:
            status = s_status[0].status

        for user in all_users:
            full_name = user.first_name + " " + user.last_name
            subcriptions = user.transactions
            value = {"name": full_name,
                     "email": user.email,
                     "subscriptions": len(subcriptions)}
            users.append(value)
        return render_template('subcribers.html', users=users, status=status)
    else:
        return render_template('404.html')


@login_required
@app_views_auth.route('/users', methods=['GET', 'POST'])
def manage_users():
    """Manage users"""
    if current_user.is_authenticated and current_user.user_type == "Admin":
        if request.method == "POST":
            user_email = request.form.get('user_email')
            user = storage.get_object(User, email=user_email)
            if user.user_type == "Admin":
                message = """Deletion failed: Cannot
                delete the administrator user."""
                flash(message, "error")
            else:
                storage.delete(user)
                storage.save()
                message = """User sucessfully deleted"""
                flash(message, "success")
            return redirect(url_for('app_views_auth.manage_users'))

        all_users = storage.get_object(User, all="trure")
        u_users = []
        for user in all_users:
            full_name = user.first_name + " " + user.last_name
            user_properties = user.properties
            u_users.append({'id': user.id, 'name': full_name,
                            'email': user.email,
                            'phone': user.phone_number,
                            'user_type': user.user_type,
                            'properties_count': len(user_properties)})
        users = sorted(u_users, key=lambda user: user["user_type"])
        return render_template('manage_users.html', users=users)
    else:
        return render_template('404.html')


@login_required
@app_views_auth.route('/advertisement', methods=['POST', 'GET'])
def manage_advertisement():
    """Manage advertisement images"""
    if current_user.is_authenticated and current_user.user_type == "Admin":
        ad_error_images = []
        image_directory = os.path.join(
            'auth', 'static', 'img', 'advertisements'
        )

        all_agents = storage.get_object(Agent, all="yes")
        existing_agents = []
        for agent in all_agents:
            name = agent.agent_name
            a_image = agent.image_url
            a_id = agent.id
            existing_agents.append(
                {'name': name, 'image': a_image, 'id': a_id})

        existing_images = [
            filename for filename in os.listdir(image_directory)
            if filename.startswith("adver_image") and
            os.path.isfile(os.path.join(image_directory, filename))
        ]

        def extract_number(file):
            match = re.search(r"(\d+)", file)
            return int(match.group(1)) if match else 0

        existing_images = sorted(existing_images, key=extract_number)

        if request.method == "POST":
            for i in range(1, 7):
                try:
                    ad_image = request.files.get(f'mainImage{i}')
                    if ad_image:
                        image = Image.open(ad_image)
                        if image.size != (1000, 1000):
                            ad_error_images.append(i)
                        else:
                            ad_image_extension = os.path.splitext(
                                ad_image.filename)[1]
                            ad_image_basename = f"adver_image_{i}"
                            ad_image_dirtory = 'auth/static/img/advertisements'
                            ad_image_filename = os.path.join(
                                ad_image_dirtory,
                                f"{ad_image_basename}{ad_image_extension}")

                            for file in os.listdir(ad_image_dirtory):
                                img = (file.startswith(ad_image_basename) and
                                       file != f"{ad_image_basename}"
                                       f"{ad_image_extension}")
                                if img:
                                    os.remove(os.path.join(
                                        ad_image_dirtory, file))
                            ad_image.seek(0)
                            ad_image.save(ad_image_filename)
                except Exception as e:
                    ad_error_images.append(1)

            agent_ids = request.form.getlist('agentIds')
            agent_names = request.form.getlist('agentNames')
            agent_images = request.files.getlist('agentImages')
            agent_dir = "auth/static/img/agents"

            os.makedirs(agent_dir, exist_ok=True)

            for idx, agent_id in enumerate(agent_ids):
                name = agent_names[idx]
                image = agent_images[idx] if idx < len(agent_images) else None

                agent = storage.get_object(Agent, id=agent_id)

                if name:
                    agent.agent_name = name

                if image:
                    try:
                        pil_image = Image.open(image)
                        if pil_image.size == (400, 400):

                            _, file_extension = os.path.splitext(
                                secure_filename(image.filename))
                            image_filename = f"{agent_id}{file_extension}"
                            image_path = os.path.join(
                                agent_dir, image_filename)

                            for file in os.listdir(agent_dir):
                                test = (file.startswith(f"{agent_id}.") and
                                        file != image_filename)
                                if test:
                                    os.remove(os.path.join(agent_dir, file))

                            pil_image.save(image_path)
                            agent.image_url = image_filename
                        else:
                            print(f"Image for agent is not 400x400 pixels.")
                            ad_error_images.append(1)
                    except Exception as e:
                        print(f"Error processing image for agent : {e}")
                agent.save()
            try:
                agent_field_count = int(request.form.get('agentFieldCount', 0))
                for i in range(1, agent_field_count + 1):
                    agent_image = request.files.get(f'agentImage{i}')
                    agent_name = request.form.get(f'agentName{i}')

                    if agent_image and agent_name:
                        image = Image.open(agent_image)

                        if image.size != (400, 400):
                            ad_error_images.append(1)
                            continue
                        agent_image.seek(0)

                        new_agent = Agent()
                        agent_image_extension = os.path.splitext(
                            agent_image.filename)[1]
                        agent_image_filename = os.path.join(
                            "auth/static/img/agents",
                            f"{new_agent.id}{agent_image_extension}")
                        image_url = os.path.join(
                            f"{new_agent.id}{agent_image_extension}")

                        agent_image.save(agent_image_filename)

                        setattr(new_agent, "agent_name", agent_name)
                        setattr(new_agent, "image_url", image_url)
                        new_agent.save()
            except ValueError:
                pass
            except Exception as e:
                print("Emtpy new agent")
                ad_error_images.append(1)
            if len(ad_error_images) != 0:
                message = """Some images were not updated due to incorrect
                image sizes or format. Please ensure all images are 1000*1000
                pixel for advertisement images and 400x400 pixels
                or agent's images"""
                flash(message, "error")
            else:
                flash("Images have been successfully updated.", "success")
            return redirect(url_for('app_views_auth.manage_advertisement'))

        return render_template('manage_advertisement.html',
                               existing_images=existing_images,
                               existing_agents=existing_agents)
    else:
        return render_template('404.html')


@app_views_auth.route('/delete-agent-image/<uuid:agent_id>',
                      methods=['DELETE'])
@login_required
def delete_agent_image(agent_id):
    """Delete agent image"""
    try:
        agent = storage.get_agent(agent_id)
        agent.delete()
        storage.save()
        agent_directory = "auth/static/img/agents"
        for file in os.listdir(agent_directory):
            if file.startswith(f"{agent_id}."):
                os.remove(os.path.join(agent_directory, file))
    except Exception as e:
        print(e)
    finally:
        return jsonify({'success': 'Image deleted successfully'}), 200


def send_email(**kwars):
    """Send a password reset email to a user
    using an external HTML template.
    """
    receiver_email = kwars.get('email')

    html_file = kwars.get('html_file')
    new_password = kwars.get('new_password')
    property_link = kwars.get('property_link')

    email = "lenomadeleineantoine@gmail.com"
    subject = "Password Reset Request - Roofmarket"
    if new_password is None:
        subject = "🏠 New Property Just Listed – Don’t Miss Out!"

    current_year = datetime.datetime.now().year

    with open("auth/templates/{}".format(html_file)) as f:
        html_content = f.read()

    html_content = html_content.replace("{{ email }}", receiver_email)
    if new_password is not None:
        html_content = html_content.replace("{{ password }}", new_password)
    else:
        html_content = html_content.replace("{{ property_link }}",
                                            str(property_link))
    html_content = html_content.replace("{{ current_year }}",
                                        str(current_year))

    msg = MIMEMultipart()
    msg['From'] = email
    msg['To'] = receiver_email
    msg['Subject'] = subject
    msg.attach(MIMEText(html_content, 'html'))

    try:
        with smtplib.SMTP("smtp.gmail.com", 587) as server:
            server.starttls()
            server.login(email, 'dwjo amny oeyf rvwi')
            server.sendmail(email, receiver_email, msg.as_string())
    except Exception as e:
        print(f"Failed to send email: {e}")


def generate_password(length=12):
    """Random password generator helper function"""
    characters = string.ascii_letters + string.digits + string.punctuation
    return ''.join(secrets.choice(characters) for i in range(length))


def update_online_status(status: bool, room_id=None):
    """Update online status"""
    if current_user.is_authenticated:
        user = storage.get_object(User, id=current_user.id)
        if room_id:
            room_participation = storage.get_object(RoomParticipants,
                                                    user_id=current_user.id,
                                                    room_id=room_id)
            room_participation.room_position = status
        else:
            room_participation = storage.get_object(RoomParticipants,
                                                    user_id=current_user.id,
                                                    all=True)
            for r_p in room_participation:
                r_p.room_position = status
        user.is_online = status
        storage.save()
