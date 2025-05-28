# routes/auth.py
import uuid
import bcrypt
import jwt
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models.user import User
from pydantic_schemas.user_create import UserCreate
from pydantic_schemas.user_login import UserLogin
from middleware.auth_middleware import auth_middleware
from pydantic_schemas.change_password import ChangePasswordRequest
from models.profile_post import UserProfile, Post, Like, Comment

router = APIRouter()

# Register a new user
@router.post("/signup", status_code=201)
def signup_user(user: UserCreate, db: Session = Depends(get_db)):
    # Check if email already exists
    existing_user = db.query(User).filter(User.email == user.email).first()
    if existing_user:
        raise HTTPException(400, "This email already exists")

    # Hash password before saving
    hashed_pw = bcrypt.hashpw(user.password.encode('utf-8'), bcrypt.gensalt())

    user_db = User(
        id=str(uuid.uuid4()),
        name=user.name,
        email=user.email,
        password=hashed_pw
    )

    db.add(user_db)
    db.commit()
    db.refresh(user_db)

    return user_db

# Login user and return token
@router.post('/login')
def login_user(user: UserLogin, db: Session = Depends(get_db)):
    user_db = db.query(User).filter(User.email == user.email).first()
    if not user_db:
        raise HTTPException(400, "User with this email doesn't exist")

    if not bcrypt.checkpw(user.password.encode(), user_db.password):
        raise HTTPException(400, "Incorrect Password")

    token = jwt.encode({'id': user_db.id}, 'password_key', algorithm='HS256')

    # Fetch profile pic
    profile = db.query(UserProfile).filter(UserProfile.user_id == user_db.id).first()
    profile_pic_url = profile.profile_pic_url if profile else None

    # Fetch posts with likes and comments
    posts = db.query(Post).filter(Post.user_id == user_db.id).order_by(Post.created_at.desc()).all()
    posts_data = []
    for post in posts:
        total_likes = db.query(Like).filter(Like.post_id == post.id).count()
        comments = db.query(Comment).filter(Comment.post_id == post.id).all()
        posts_data.append({
            'id': post.id,
            'content': post.content,
            'media_url': post.media_url,
            'created_at': post.created_at,
            'total_likes': total_likes,
            'comments': [
                {
                    'id': c.id,
                    'text': c.text,
                    'user_id': c.user_id,
                    'created_at': c.created_at
                } for c in comments
            ]
        })

    return {
        'token': token,
        'user': {
            'id': user_db.id,
            'name': user_db.name,
            'email': user_db.email,
            'profile_pic_url': profile_pic_url,
            'posts': posts_data
        }
    }

# change password
@router.post("/change-password")
def change_password(request: ChangePasswordRequest, db: Session = Depends(get_db)):
    # Step 1: Check if user exists by email
    user_db = db.query(User).filter(User.email == request.email).first()
    if not user_db:
        raise HTTPException(404, "User not found")

    # Step 2: Verify current password
    if not bcrypt.checkpw(request.current_password.encode(), user_db.password):
        raise HTTPException(400, "Current password is incorrect")

    # Step 3: Hash new password
    new_hashed_pw = bcrypt.hashpw(request.new_password.encode('utf-8'), bcrypt.gensalt())
    user_db.password = new_hashed_pw

    # Step 4: Commit changes
    db.commit()
    db.refresh(user_db)

    return {"message": "Password changed successfully"}

# Protected route to fetch current user info
@router.get('/')
def current_user_data(db: Session = Depends(get_db), user_dict=Depends(auth_middleware)):
    user = db.query(User).filter(User.id == user_dict['uid']).first()
    if not user:
        raise HTTPException(404, "User not found")

    profile = db.query(UserProfile).filter(UserProfile.user_id == user.id).first()
    profile_pic_url = profile.profile_pic_url if profile else None

    posts = db.query(Post).filter(Post.user_id == user.id).order_by(Post.created_at.desc()).all()
    posts_data = []
    for post in posts:
        total_likes = db.query(Like).filter(Like.post_id == post.id).count()
        comments = db.query(Comment).filter(Comment.post_id == post.id).all()
        posts_data.append({
            'id': post.id,
            'content': post.content,
            'media_url': post.media_url,
            'created_at': post.created_at,
            'total_likes': total_likes,
            'comments': [
                {
                    'id': c.id,
                    'text': c.text,
                    'user_id': c.user_id,
                    'created_at': c.created_at
                } for c in comments
            ]
        })

    return {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'profile_pic_url': profile_pic_url,
        'posts': posts_data
    }

# Get another user's profile and posts
@router.get('/user/{user_id}')
def get_user_profile(user_id: str, db: Session = Depends(get_db)):
    from models.profile_post import UserProfile, Post, Like, Comment
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(404, "User not found")
    profile = db.query(UserProfile).filter(UserProfile.user_id == user_id).first()
    profile_pic_url = profile.profile_pic_url if profile else None
    posts = db.query(Post).filter(Post.user_id == user_id).order_by(Post.created_at.desc()).all()
    posts_data = []
    for post in posts:
        total_likes = db.query(Like).filter(Like.post_id == post.id).count()
        comments = db.query(Comment).filter(Comment.post_id == post.id).all()
        posts_data.append({
            'id': post.id,
            'content': post.content,
            'media_url': post.media_url,
            'created_at': post.created_at,
            'total_likes': total_likes,
            'comments': [
                {
                    'id': c.id,
                    'text': c.text,
                    'user_id': c.user_id,
                    'created_at': c.created_at
                } for c in comments
            ]
        })
    return {
        'id': user.id,
        'name': user.name,
        'profile_pic_url': profile_pic_url,
        'posts': posts_data
    }
