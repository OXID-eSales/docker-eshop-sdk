FROM debian:latest

ENV LANG en_US.utf8

RUN apt-get update && \
    apt-get install -y git python3-pip plantuml graphviz openjdk-11-jre && \
    pip install -U Sphinx && \
    pip install git+https://github.com/fabpot/sphinx-php.git && \
    pip install sphinx_rtd_theme && \
    pip install sphinxcontrib-httpdomain && \
    pip install sphinxcontrib_plantuml && \
    pip install sphinxcontrib_phpdomain && \
    pip install pygments-graphql && \
    java -jar ./usr/share/plantuml/plantuml.jar -testdot
