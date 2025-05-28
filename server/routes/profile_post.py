import uuid
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from database import get_db
from models.user import User
from models.profile_post import UserProfile, Post, Like, Comment
from pydantic_schemas.profile_post import UserProfileUpdate, PostCreate, CommentCreate
from middleware.auth_middleware import auth_middleware
import cloudinary
import cloudinary.uploader
import random

# Cloudinary config (move here to ensure it's always set)
cloudinary.config(
    cloud_name = "diqoy7rc4",
    api_key = "683212584585384",
    api_secret = "LZWJKJnReDXhMC2jlb272RouMCw",
    secure=True
)

def upload_media_to_cloudinary(file, user_id, is_profile_pic=False):
    """
    Uploads a file object to Cloudinary in the connectify/user_id/profile_pic or connectify/user_id/posts folder and returns the URL.
    """
    if is_profile_pic:
        folder_path = f"connectify/{user_id}/profile_pic"
    else:
        folder_path = f"connectify/{user_id}/posts"
    result = cloudinary.uploader.upload(file, folder=folder_path)
    return result.get('secure_url')

router = APIRouter()

# Get or update user profile
@router.get('/profile')
def get_profile(db: Session = Depends(get_db), user_dict=Depends(auth_middleware)):
    profile = db.query(UserProfile).filter(UserProfile.user_id == user_dict['uid']).first()
    if not profile:
        # Instead of 404, return a default or null profile_pic_url
        return {'profile_pic_url': None}
    return {'profile_pic_url': profile.profile_pic_url}

@router.put('/profile/pic')
def update_profile_pic(db: Session = Depends(get_db), user_dict=Depends(auth_middleware), file: UploadFile = File(...)):
    # Ensure user exists
    user = db.query(User).filter(User.id == user_dict['uid']).first()
    if not user:
        raise HTTPException(404, 'User not found')
    profile = db.query(UserProfile).filter(UserProfile.user_id == user_dict['uid']).first()
    url = upload_media_to_cloudinary(file.file, user_id=user_dict['uid'], is_profile_pic=True)
    if not profile:
        profile = UserProfile(id=str(uuid.uuid4()), user_id=user_dict['uid'], profile_pic_url=url)
        db.add(profile)
    else:
        profile.profile_pic_url = url
    db.commit()
    db.refresh(profile)
    return {'profile_pic_url': url}

# DELETE /media/profile/pic
@router.delete('/profile/pic')
def delete_profile_pic(db: Session = Depends(get_db), user_dict=Depends(auth_middleware)):
    profile = db.query(UserProfile).filter(UserProfile.user_id == user_dict['uid']).first()
    if not profile or not profile.profile_pic_url:
        return {'detail': 'No profile picture to delete.'}
    # Extract public_id from the Cloudinary URL
    import re
    match = re.search(r'/connectify/.+?/profile_pic/(.+)\.', profile.profile_pic_url)
    public_id = None
    if match:
        public_id = f"connectify/{user_dict['uid']}/profile_pic/{match.group(1)}"
    if public_id:
        try:
            cloudinary.uploader.destroy(public_id)
        except Exception:
            pass
    profile.profile_pic_url = None
    db.commit()
    db.refresh(profile)
    return {'detail': 'Profile picture deleted.'}

# Create a post
@router.post('/posts')
def create_post(db: Session = Depends(get_db), user_dict=Depends(auth_middleware), content: str = Form(None), file: UploadFile = File(None)):
    media_url = None
    if file:
        media_url = upload_media_to_cloudinary(file.file, user_id=user_dict['uid'], is_profile_pic=False)
    post = Post(id=str(uuid.uuid4()), user_id=user_dict['uid'], content=content, media_url=media_url)
    db.add(post)
    db.commit()
    db.refresh(post)
    return {'id': post.id, 'content': post.content, 'media_url': post.media_url, 'created_at': post.created_at}

# Get all posts by current user
@router.get('/posts')
def get_my_posts(db: Session = Depends(get_db), user_dict=Depends(auth_middleware)):
    posts = db.query(Post).filter(Post.user_id == user_dict['uid']).order_by(Post.created_at.desc()).all()
    result = []
    for post in posts:
        total_likes = db.query(Like).filter(Like.post_id == post.id).count()
        liked_by_user = db.query(Like).filter(Like.post_id == post.id, Like.user_id == user_dict['uid']).first() is not None
        comments = db.query(Comment).filter(Comment.post_id == post.id).all()
        result.append({
            'id': post.id,
            'content': post.content,
            'media_url': post.media_url,
            'created_at': post.created_at,
            'total_likes': total_likes,
            'liked_by_user': liked_by_user,
            'comments': [
                {
                    'id': c.id,
                    'text': c.text,
                    'user_id': c.user_id,
                    'user_name': db.query(User).filter(User.id == c.user_id).first().name if c.user_id else None,
                    'created_at': c.created_at
                } for c in comments
            ]
        })
    return result

# Like/unlike a post
@router.post('/posts/{post_id}/like')
def like_post(post_id: str, db: Session = Depends(get_db), user_dict=Depends(auth_middleware)):
    like = db.query(Like).filter(Like.post_id == post_id, Like.user_id == user_dict['uid']).first()
    if like:
        db.delete(like)
        db.commit()
        return {'liked': False}
    else:
        new_like = Like(id=str(uuid.uuid4()), post_id=post_id, user_id=user_dict['uid'])
        db.add(new_like)
        db.commit()
        return {'liked': True}

# Add comment to a post
@router.post('/posts/{post_id}/comments')
def add_comment(post_id: str, comment: CommentCreate, db: Session = Depends(get_db), user_dict=Depends(auth_middleware)):
    new_comment = Comment(id=str(uuid.uuid4()), post_id=post_id, user_id=user_dict['uid'], text=comment.text)
    db.add(new_comment)
    db.commit()
    db.refresh(new_comment)
    return {'id': new_comment.id, 'text': new_comment.text, 'user_id': new_comment.user_id, 'created_at': new_comment.created_at}

# Get comments for a post
@router.get('/posts/{post_id}/comments')
def get_comments(post_id: str, db: Session = Depends(get_db)):
    comments = db.query(Comment).filter(Comment.post_id == post_id).order_by(Comment.created_at).all()
    return [
        {
            'id': c.id,
            'text': c.text,
            'user_id': c.user_id,
            'user_name': db.query(User).filter(User.id == c.user_id).first().name if c.user_id else None,
            'created_at': c.created_at
        } for c in comments
    ]

# View a single post by its id
@router.get('/posts/{post_id}')
def get_single_post(post_id: str, db: Session = Depends(get_db), user_dict=Depends(auth_middleware)):
    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(404, 'Post not found')
    total_likes = db.query(Like).filter(Like.post_id == post.id).count()
    liked_by_user = db.query(Like).filter(Like.post_id == post.id, Like.user_id == user_dict['uid']).first() is not None
    comments = db.query(Comment).filter(Comment.post_id == post.id).all()
    return {
        'id': post.id,
        'content': post.content,
        'media_url': post.media_url,
        'created_at': post.created_at,
        'total_likes': total_likes,
        'liked_by_user': liked_by_user,
        'comments': [
            {
                'id': c.id,
                'text': c.text,
                'user_id': c.user_id,
                'user_name': db.query(User).filter(User.id == c.user_id).first().name if c.user_id else None,
                'created_at': c.created_at
            } for c in comments
        ]
    }

# View another user's profile picture by user_id
@router.get('/profile/user/{user_id}')
def get_other_user_profile_pic(user_id: str, db: Session = Depends(get_db)):
    profile = db.query(UserProfile).filter(UserProfile.user_id == user_id).first()
    if not profile:
        # Return a default image URL or None
        return {'profile_pic_url': None}
    return {'profile_pic_url': profile.profile_pic_url}

# Feed: Get all posts from all users except the current user, shuffled
@router.get('/feed')
def get_feed(db: Session = Depends(get_db), user_dict=Depends(auth_middleware)):
    # Get all posts except current user's
    posts = db.query(Post).filter(Post.user_id != user_dict['uid']).all()
    # Shuffle posts for feed randomness
    random.shuffle(posts)
    feed = []
    for post in posts:
        user = db.query(User).filter(User.id == post.user_id).first()
        profile = db.query(UserProfile).filter(UserProfile.user_id == post.user_id).first()
        profile_pic_url = profile.profile_pic_url if profile else None
        total_likes = db.query(Like).filter(Like.post_id == post.id).count()
        liked_by_user = db.query(Like).filter(Like.post_id == post.id, Like.user_id == user_dict['uid']).first() is not None
        comments = db.query(Comment).filter(Comment.post_id == post.id).all()
        feed.append({
            'post_id': post.id,
            'user_id': post.user_id,
            'user_name': user.name if user else None,
            'profile_pic_url': profile_pic_url,
            'content': post.content,
            'media_url': post.media_url,
            'created_at': post.created_at,
            'total_likes': total_likes,
            'liked_by_user': liked_by_user,
            'comments': [
                {
                    'id': c.id,
                    'text': c.text,
                    'user_id': c.user_id,
                    'user_name': db.query(User).filter(User.id == c.user_id).first().name if c.user_id else None,
                    'created_at': c.created_at
                } for c in comments
            ]
        })
    return feed
