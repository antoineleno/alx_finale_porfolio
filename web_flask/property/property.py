#!/usr/bin/python3
"""Property module"""

from property  import app_views_property
from flask import render_template, abort, request, jsonify
from models import storage
from models.property import Property
from models.property_image import Property_image


@app_views_property.route("/property/<property_id>", methods = ["GET"])
def property_onclick(property_id):
    the_property = storage.get_property_by_id(property_id)
    if not the_property:
        abort(404, description="Bad request: Property not found")

    the_property_images = storage.get_image(property_id)
    property_dict = {}
    for image in the_property_images:
        property_dict[image.image_type] = image.image_url
    print(property_dict)
    property_dict["title"] = the_property.title
    property_dict["description"] = the_property.description
    property_dict["price"] = the_property.price
    property_dict["listing_type"] = the_property.listing_type

    return render_template("property.html", property=property_dict)



@app_views_property.route("/property_list")
def property_list():

    per_page = 3  # Number of properties per page
    property_type = request.args.get('type', None)
    if property_type not in ["apartment", "studio", "house", "villa"]:
        property_type = None
    country = request.args.get('country', None)
    city = request.args.get('city', None)
    max_price = request.args.get('max_price', None)
    min_price = request.args.get('min_price', None)
    total_properties = 0
    if country and city and property_type and max_price and min_price:
        # Get the total number of properties
        print(property_type)
        total_properties = storage.count(Property, property_type, country, city, max_price, min_price)
        print(total_properties)

    else:
        # Get the total number of properties
        total_properties = storage.count(Property, property_type) 
    if per_page > total_properties:
        per_page = total_properties
    
    total_pages = 0
    if per_page != 0:
        total_pages = (total_properties + per_page - 1) // per_page  # Total pages required

    countries = storage.get_countries()

    return render_template('property_listing.html', countries=countries, total_pages=total_pages, property_type=property_type, per_page=per_page, country=country, city=city, max_price=max_price, min_price=min_price)
  

@app_views_property.route("/page_generation")
def page_generation():
    per_page = int(request.args['per_page'])  # Number of properties per page
    page = int(request.args.get('page', 1))  # Get current page from query parameters
    offset = (page - 1) * per_page
    property_type = request.args.get('property_type', None)
    country = request.args.get('country', None)
    city = request.args.get('city', None)
    max_price = request.args.get('max_price', None)
    min_price = request.args.get('min_price', None)
    if country == 'None':
        country = None
    if city == 'None':
        city = None
    if max_price == 'None':
        max_price = None
    if min_price == 'None':
        min_price = None
    if property_type not in ["apartment", "studio", "house", "villa"] or property_type == 'None':
        property_type = None

    # Query properties with limit and offset
    property_objs = storage.property_objs(per_page, offset, property_type, country, city, max_price, min_price)

    property_list = []
    for obj in property_objs:
        # Retrieve property images and select the main image URL
        main_image_obj = storage.get_image(obj.id, "Main_image")
    
        
        # Append property details to the list
        property_list.append({
            "id": obj.id,
            "title": obj.title,
            "property_type": obj.property_type,
            "price": obj.price,
            "listing_type": obj.listing_type,
            "address": obj.address,
            "city": obj.city,
            "country": obj.country,
            "bedrooms": obj.bedrooms,
            "bathrooms": obj.bathrooms,
            "area": obj.area,
            "Main_image_url": main_image_obj.image_url
        })

    #return render_template("index.html", properties=property_list, page=page, total_pages=total_pages)
    #return property_list
    #return render_template('property_listing.html', properties=property_list)
    return jsonify({
        "properties": property_list
        }) 


@app_views_property.route("/property_types")
def property_types():


    Number_per_type ={"apartment": storage.count(Property, "apartment"), "villa": storage.count(Property, "villa"), 
                      "studio": storage.count(Property, "studio"), "house":storage.count(Property, "house") }
    return render_template('property-type.html', Number_per_type=Number_per_type)
