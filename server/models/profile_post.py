from sqlalchemy import Column, String, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from models.base import Base

class UserProfile(Base):
    __tablename__ = 'user_profiles'
    id = Column(String, primary_key=True, index=True)
    user_id = Column(String, ForeignKey('users.id'), unique=True)
    profile_pic_url = Column(String, nullable=True)
    user = relationship('User', back_populates='profile')

class Post(Base):
    __tablename__ = 'posts'
    id = Column(String, primary_key=True, index=True)
    user_id = Column(String, ForeignKey('users.id'))
    content = Column(String, nullable=True)
    media_url = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    user = relationship('User', back_populates='posts')
    likes = relationship('Like', back_populates='post', cascade='all, delete')
    comments = relationship('Comment', back_populates='post', cascade='all, delete')

class Like(Base):
    __tablename__ = 'likes'
    id = Column(String, primary_key=True, index=True)
    user_id = Column(String, ForeignKey('users.id'))
    post_id = Column(String, ForeignKey('posts.id'))
    post = relationship('Post', back_populates='likes')

class Comment(Base):
    __tablename__ = 'comments'
    id = Column(String, primary_key=True, index=True)
    user_id = Column(String, ForeignKey('users.id'))
    post_id = Column(String, ForeignKey('posts.id'))
    text = Column(String)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    post = relationship('Post', back_populates='comments')
