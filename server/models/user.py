from sqlalchemy import Column, String, Integer, LargeBinary
from models.base import Base
from sqlalchemy.dialects.postgresql import TEXT, VARCHAR
from sqlalchemy.orm import relationship

class User(Base):
    __tablename__ = 'users'
    id = Column(TEXT, primary_key=True)
    name = Column(VARCHAR(100))
    email = Column(VARCHAR(100), unique=True)
    password = Column(LargeBinary)  # Use LargeBinary from sqlalchemy
    
    # Add these relationship properties
    profile = relationship('UserProfile', back_populates='user', uselist=False)
    posts = relationship('Post', back_populates='user')