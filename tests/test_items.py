def test_create_item(client, auth_headers):
    response = client.post(
        "/items",
        json={
            "name": "Test Laptop",
            "description": "Test item",
            "price": 1000,
        },
        headers=auth_headers,
    )

    assert response.status_code == 201

    data = response.json()

    assert data["name"] == "Test Laptop"
    assert data["description"] == "Test item"
    assert data["price"] == 1000
    assert "id" in data


def test_get_items(client, auth_headers):
    client.post(
        "/items",
        json={
            "name": "Laptop",
            "description": "Development laptop",
            "price": 1200,
        },
        headers=auth_headers,
    )

    client.post(
        "/items",
        json={
            "name": "Keyboard",
            "description": "Mechanical keyboard",
            "price": 100,
        },
        headers=auth_headers,
    )

    response = client.get(
        "/items",
        headers=auth_headers,
    )

    assert response.status_code == 200

    data = response.json()

    assert len(data) == 2
    assert data[0]["name"] == "Laptop"
    assert data[1]["name"] == "Keyboard"


def test_get_single_item(client, auth_headers):
    create_response = client.post(
        "/items",
        json={
            "name": "Monitor",
            "description": "4K monitor",
            "price": 500,
        },
        headers=auth_headers,
    )

    item_id = create_response.json()["id"]

    response = client.get(
        f"/items/{item_id}",
        headers=auth_headers,
    )

    assert response.status_code == 200

    data = response.json()

    assert data["id"] == item_id
    assert data["name"] == "Monitor"
    assert data["price"] == 500


def test_get_nonexistent_item(client, auth_headers):
    response = client.get(
        "/items/99999",
        headers=auth_headers,
    )

    assert response.status_code == 404

    assert response.json() == {
        "detail": "Item not found"
    }


def test_update_item(client, auth_headers):
    create_response = client.post(
        "/items",
        json={
            "name": "Old Laptop",
            "description": "Old description",
            "price": 1000,
        },
        headers=auth_headers,
    )

    item_id = create_response.json()["id"]

    response = client.put(
        f"/items/{item_id}",
        json={
            "name": "New Laptop",
            "description": "Updated description",
            "price": 1500,
        },
        headers=auth_headers,
    )

    assert response.status_code == 200

    data = response.json()

    assert data["id"] == item_id
    assert data["name"] == "New Laptop"
    assert data["description"] == "Updated description"
    assert data["price"] == 1500


def test_delete_item(client, auth_headers):
    create_response = client.post(
        "/items",
        json={
            "name": "Delete Me",
            "description": "Temporary item",
            "price": 50,
        },
        headers=auth_headers,
    )

    item_id = create_response.json()["id"]

    response = client.delete(
        f"/items/{item_id}",
        headers=auth_headers,
    )

    assert response.status_code == 204

    get_response = client.get(
        f"/items/{item_id}",
        headers=auth_headers,
    )

    assert get_response.status_code == 404