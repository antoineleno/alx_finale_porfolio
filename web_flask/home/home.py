#!/usr/bin/python3
"""Home module"""

from home import app_views_home
from flask import render_template, jsonify, request
from models import storage
from models.property import Property
from models.property_image import Property_image
import os
import re
from models.user import User


@app_views_home.route("/")
def home():
    """Home"""
    image_directory = os.path.join(
            'auth', 'static', 'img', 'advertisements'
        )
    existing_images = [
        filename for filename in os.listdir(image_directory)
        if filename.startswith("adver_image") and
        os.path.isfile(os.path.join(image_directory, filename))
    ]

    def extract_number(file):
        match = re.search(r"(\d+)", file)
        return int(match.group(1)) if match else 0

    existing_images = sorted(existing_images, key=extract_number)

    admin_object = storage.get_object(User, user_type="Admin")
    admin_email = admin_object.email
    admin_phone_number = admin_object.phone_number
    per_page = 9
    property_objs = []
    feature = request.args.get('feature', None)
    if feature not in ['featured', 'sell', 'rent']:
        feature = 'featured'
    if feature in [None, 'featured']:

        total_objs = storage.count(Property)
        if per_page > total_objs:
            per_page = total_objs
        property_objs = storage.property_objs(per_page, 0)

    elif feature == "sell":
        total_objs = storage.count(Property, listing_type="sell")
        if per_page > total_objs:
            per_page = total_objs
        property_objs = storage.property_objs(per_page, 0, listing_type="sell")

    elif feature == "rent":
        total_objs = storage.count(Property, listing_type="rent")
        if per_page > total_objs:
            per_page = total_objs
        property_objs = storage.property_objs(per_page, 0, listing_type="rent")

    property_list = []

    for obj in property_objs:

        Main_image_obj = storage.get_image(obj.id, "Main_image")

        property_list.append({"id": obj.id, "title": obj.title,
                              "property_type": obj.property_type.title(),
                              "price": obj.price,
                              "listing_type": obj.listing_type,
                              "address": obj.address, "city": obj.city,
                              "country": obj.country, "bedrooms": obj.bedrooms,
                              "bathrooms": obj.bathrooms, "area": obj.area,
                              "Main_image_url": Main_image_obj.image_url})

    Number_per_type = {"apartment": storage.count(Property, "apartment"),
                       "villa": storage.count(Property, "villa"),
                       "studio": storage.count(Property, "studio"),
                       "house": storage.count(Property, "house")}

    countries = storage.get_countries()

    return render_template("index.html", properties=property_list,
                           Number_per_type=Number_per_type,
                           countries=countries, feature=feature,
                           window="home",
                           existing_images=existing_images,
                           admin_email=admin_email,
                           admin_phone_number=admin_phone_number)


@app_views_home.route("/get_cities/<country>")
def get_cities(country):
    # Fetch distinct cities for the given country from the database
    cities = storage.get_cities(country)
    # Flatten the list of tuples into a simple list of cities
    cities_list = [city[0] for city in cities]
    return jsonify(cities_list)
