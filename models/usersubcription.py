#!/usr/bin/python3
"""User module"""
from models.base_model import BaseModel, Base
from sqlalchemy import Column, String, ForeignKey
from sqlalchemy.orm import relationship


class UserSubcription(BaseModel, Base):
    """Subcription"""
    __tablename__="usersubcription"
    user_id = Column(String(60), ForeignKey("user.id"), nullable=False, unique=True)
    user = relationship("User", back_populates="subscriptions")
