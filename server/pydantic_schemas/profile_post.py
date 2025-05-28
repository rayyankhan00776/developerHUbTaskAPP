from pydantic import BaseModel
from typing import Optional

class UserProfileUpdate(BaseModel):
    profile_pic_url: Optional[str] = None

class PostCreate(BaseModel):
    content: Optional[str] = None
    media_url: Optional[str] = None

class CommentCreate(BaseModel):
    text: str

class LikeResponse(BaseModel):
    total_likes: int
    liked_by_user: bool

class PostResponse(BaseModel):
    id: str
    content: Optional[str]
    media_url: Optional[str]
    created_at: str
    total_likes: int
    liked_by_user: bool
    comments: list
