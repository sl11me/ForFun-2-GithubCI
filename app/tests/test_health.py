from app.main import health, version

def test_health():
    """Test de l'endpoint health"""
    result = health()
    assert result == {"status": "ok"}
    assert "status" in result
    assert result["status"] == "ok"

def test_version():
    """Test de l'endpoint version"""
    result = version()
    assert "version" in result
    assert isinstance(result["version"], str)
