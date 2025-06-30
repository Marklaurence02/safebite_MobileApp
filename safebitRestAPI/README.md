# SafeBit REST API

This project is a Node.js/Express REST API designed for integration with a Flutter app. It implements endpoints for users, sensors, readings, alerts, food items, activity logs, and sessions, matching the provided MySQL schema.

## Features
- User registration, authentication, and management
- Sensor CRUD and assignment
- Reading submission and retrieval
- Alert creation and listing
- Food item management
- Activity logging
- Session management (token-based)

## Setup
1. Install dependencies:
'''
npm install
'''
2. Configure your database connection in `.env` (to be created).
3. Run the server:
'''
npm start
'''

## Endpoints
- `/api/users` (register, login, CRUD)
- `/api/sensors` (CRUD)
- `/api/readings` (CRUD)
- `/api/alerts` (CRUD)
- `/api/food-items` (CRUD)
- `/api/activity-logs` (list)
- `/api/sessions` (token management)

## Next Steps
- Implement models, controllers, and routes for each table.
- Add authentication middleware.
- Connect to MySQL using `mysql2` or `sequelize`.

---

This file will be updated as the implementation progresses.