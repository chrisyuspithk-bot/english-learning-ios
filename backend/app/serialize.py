from datetime import date, datetime


def serialize(obj, exclude=None):
    """Convert a SQLAlchemy model instance into a plain JSON-ready dict."""
    exclude = exclude or set()
    out = {}
    for column in obj.__table__.columns:
        if column.name in exclude:
            continue
        value = getattr(obj, column.name)
        if isinstance(value, (datetime, date)):
            value = value.isoformat()
        out[column.name] = value
    return out
