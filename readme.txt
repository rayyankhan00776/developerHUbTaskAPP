# In-App Notification System Documentation

## Overview
This project implements an in-app notification system using FastAPI and SQLAlchemy. Notifications are stored in the database and can be fetched by the frontend (e.g., Flutter app) to display to users when they click the bell icon in the app bar.

## Database Structure
- **Table:** `notifications`
- **Model:** `Notification` (see `models/notification.py`)
- **Fields:**
  - `id`: Integer, primary key
  - `user_id`: String, recipient user (ForeignKey to users)
  - `type`: String (e.g., "like", "message")
  - `message`: String (e.g., "rayyan123 liked your post.")
  - `data`: JSON (optional, extra info like post_id, conversation_id)
  - `is_read`: Boolean (default False)
  - `created_at`: DateTime

## How Notifications Are Created
- Use the `create_notification` function:
  ```python
  create_notification(db, recipient_user_id, notif_type, actor_user_id, data=None)
  ```
- The function automatically generates a message like:
  - "username liked your post."
  - "username sent you a message."
- Call this function after a like or message event, passing the recipient's user ID, the type ("like" or "message"), the actor's user ID, and any extra data (e.g., post ID).

## API Endpoints
- `GET /auth/notifications`  
  Returns all notifications for the logged-in user, ordered by newest first.
  - Response example:
    ```json
    [
      {
        "id": 1,
        "type": "like",
        "message": "rayyan123 liked your post.",
        "data": {"post_id": "..."},
        "is_read": false,
        "created_at": "2025-06-25T12:34:56"
      }
    ]
    ```

- `POST /auth/notifications/mark-read`  
  Marks notifications as read. Pass a list of notification IDs in the request body.
  - Example body:
    ```json
    [1, 2, 3]
    ```

## Usage in App
- When a user likes a post or sends a message, call `create_notification` in the backend.
- The frontend fetches `/auth/notifications` to display notifications.
- When the user views notifications, call `/auth/notifications/mark-read` to mark them as read.
- The bell icon in the app bar opens the notifications page, which lists all notifications for the user.
- Unread notifications are highlighted with a green dot and can be marked as read by tapping them.

## Example Notification Flow
1. User A likes User B's post.
2. Backend calls:
   ```python
   create_notification(db, recipient_user_id=B_id, notif_type="like", actor_user_id=A_id, data={"post_id": post_id})
   ```
3. User B opens the app and fetches `/auth/notifications` to see: "UserA liked your post."
4. User B clicks the notification, and the app calls `/auth/notifications/mark-read` to mark it as read.

## Notes
- No push notifications are sent; all notifications are in-app only.
- The notification message is auto-generated to include the actor's username and action.
- You can extend the system for other actions (e.g., follow, comment) by adding more types.
