# Chatting application using Ruby on rails

It allows creating new applications where each application can have multiple chats, and each chat contains multiple messages. 

Table of contents:
* Demo
* Dependencies
* How to run 
* Versions used
* Endpoints
* Services (job queues, cache servers, search engines, etc.)

### Demo

[Watch the demo video](https://drive.google.com/file/d/1S2Vc58th7woLNW54hptBNw4J7j8SRtJb/view?usp=sharing)



### Dependencies
1. Docker
2. Docker Compose

### How to run
1. Clone the repo
2. Run docker-compose using the following command
```
docker-compose up
```

### Versions used
- **Ruby on rails:** v7.2.0.beta2
- **Ruby:** 3.3.3
- **Docker:** v27.0.2
- **Docker compose:** v2.27.1


### Endpoints
#### `ApplicationsController`

- **GET** `/applications` - Retrieves all applications.
- **GET** `/applications/:token` - Retrieves a specific application.
- **POST** `/applications` - Creates a new application.
- **PATCH/PUT** `/applications/:token` - Updates an existing application.
- **DELETE** `/applications/:token` - Deletes an application.

#### `ChatsController`

- **GET** `/chats` - Retrieves all chats within an app.
- **GET** `/chats/:number` - Retrieves a specific chat within an app.
- **POST** `/chats` - Creates a new chat within an app.
- **DELETE** `/chats/:number` - Deletes a chat from an app.

#### `MessagesController`

- **GET** `/messages` - Retrieves all messages within a chat.
- **GET** `/messages/:number` - Retrieves a specific message within a chat.
- **POST** `/messages` - Creates a new message within a chat.
- **PATCH/PUT** `/messages/:number` - Updates an existing message within a chat.
- **DELETE** `/messages/:number` - Deletes a message from a chat.
- **POST** `/messages/search` - Searches messages by a query parameter within a chat.

### Services

1. Elasticsearch
2. MySQL
3. Redis
4. Redlock
5. Searchkick
6. Sidekiq
    
