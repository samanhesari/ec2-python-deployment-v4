from sqlalchemy import text


def test_database_connection(database_engine):
    with database_engine.connect() as connection:
        result = connection.execute(text("SELECT 1"))

        assert result.scalar() == 1