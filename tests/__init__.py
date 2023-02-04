from django.test import TestCase

class AppTestCase(TestCase):
  def setUp(self) -> None:
    print('Setting up')

  def test_sample(self):
    print('Running sample test case')
