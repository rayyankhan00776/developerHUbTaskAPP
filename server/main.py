# main.py
from fastapi import FastAPI 
from models.base import Base
from routes import auth, profile_post
from database import engine

app = FastAPI()

# Register the /auth routes
app.include_router(auth.router, prefix='/auth')
app.include_router(profile_post.router, prefix="/media")

# Create database tables automatically
Base.metadata.create_all(engine)

