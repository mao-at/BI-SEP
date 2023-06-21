import pytest
from calculator import Calculator

def test_add():
    calculator = Calculator()
    result = calculator.add(3, 4)
    assert result == 7

def test_subtract():
    calculator = Calculator()
    result = calculator.subtract(10, 5)
    assert result == 5

def test_multiply():
    calculator = Calculator()
    result = calculator.multiply(4, 5)
    assert result == 20

def test_divide():
    calculator = Calculator()
    result = calculator.divide(10, 2)
    assert result == 6

def test_divide_by_zero():
    calculator = Calculator()
    # check to make sure that ValueError is raised when dividing by zero
    with pytest.raises(ValueError):
        calculator.divide(10, 0)

