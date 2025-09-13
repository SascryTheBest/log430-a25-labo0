"""
Calculator app tests
SPDX - License - Identifier: LGPL - 3.0 - or -later
Auteurs : Gabriel C. Ullmann, Fabio Petrillo, 2025
"""
import pytest
from ..calculator import Calculator

def test_app():
    my_calculator = Calculator()
    assert my_calculator.get_hello_message() == "== Calculatrice v1.0 =="

def test_addition():
    my_calculator = Calculator()
    assert my_calculator.addition(2, 3) == 5
    assert my_calculator.addition(-1, 5) == 4


def test_soustraction():
    my_calculator = Calculator()
    assert my_calculator.subtraction(10, 7) == 3
    assert my_calculator.subtraction(0, 5) == -5


def test_multiplication():
    my_calculator = Calculator()
    assert my_calculator.multiplication(4, 6) == 24
    assert my_calculator.multiplication(-2, 3) == -6


def test_division():
    my_calculator = Calculator()
    assert my_calculator.division(8, 2) == 4
    assert pytest.approx(my_calculator.division(7, 2)) == 3.5


def test_division_par_zero():
    my_calculator = Calculator()
    assert my_calculator.division(5, 0) == "Erreur : division par zéro"

def test_ci_cd():
    """ Test pour vérifier le pipeline CI/CD 
    rien à voir avec la calculatrice
    le test fait rien d'utile autre que me permettre de verifier que le pipeline CI/CD fonctionne pour l'instant
    le test est dit reussi si dans le fichier "C:\Users\Assal\apps\log430-a25-labo0" on voit que le document est a jour
    """
    print("Test CI/CD réussi") # Juste pour vérifier le pipeline CI/CD


"""
def test_donne_erreur():
    my_calculator = Calculator()
    assert my_calculator.division(5, 0) == "Ne remet pas ce texte"
"""

# TODO: ajoutez les tests