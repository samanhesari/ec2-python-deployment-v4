def test_register_user(client):
    response = client.post(
        "/auth/register",
        json={
            "username": "testuser",
            "password": "password123",
        },
    )

    assert response.status_code == 201

    data = response.json()

    assert data["username"] == "testuser"
    assert "id" in data
    assert "password" not in data
    assert "password_hash" not in data


def test_register_duplicate_user(client):
    client.post(
        "/auth/register",
        json={
            "username": "testuser",
            "password": "password123",
        },
    )

    response = client.post(
        "/auth/register",
        json={
            "username": "testuser",
            "password": "password123",
        },
    )

    assert response.status_code == 409


def test_login(client):
    client.post(
        "/auth/register",
        json={
            "username": "testuser",
            "password": "password123",
        },
    )

    response = client.post(
        "/auth/login",
        data={
            "username": "testuser",
            "password": "password123",
        },
    )

    assert response.status_code == 200

    data = response.json()

    assert "access_token" in data
    assert data["token_type"] == "bearer"


def test_login_invalid_password(client):
    client.post(
        "/auth/register",
        json={
            "username": "testuser",
            "password": "password123",
        },
    )

    response = client.post(
        "/auth/login",
        data={
            "username": "testuser",
            "password": "wrongpassword",
        },
    )

    assert response.status_code == 401


def test_protected_endpoint_without_token(client):
    response = client.get("/items")

    assert response.status_code == 401