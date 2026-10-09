from setuptools import setup, find_packages

setup(
    name="template",
    version="0.0.0",
    author="",
    author_email="",
    description="A generic template for LOKI systems.",
    url="",
    packages=find_packages("src"),
    package_dir={"": "src"},
    install_requires=[
        "odin_control>=2.0.0",
        "tornado>=4.3",
        "future",
        "requests",
    ],
    python_requires=">=3.7",
)
