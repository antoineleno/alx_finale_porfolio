#!/usr/bin/python3
"""User module"""
from models.base_model import BaseModel, Base
from sqlalchemy import Column, String, ForeignKey
from sqlalchemy.orm import relationship


class UserSubcription(BaseModel, Base):
    """Subcription"""
    __tablename__="usersubcription"
    user_email = Column(String(60), nullable=False, unique=True)
