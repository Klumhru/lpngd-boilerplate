# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
import os

_p = lambda *a: os.path.abspath(os.path.join(*a))

BASE_DIR = _p(os.path.dirname(__file__))

ROOT_DIR = _p(BASE_DIR, '..', '..', '..')

STATIC_ROOT = _p(ROOT_DIR, 'staticfiles')
if not os.path.isdir(STATIC_ROOT):
	os.mkdir(STATIC_ROOT)
