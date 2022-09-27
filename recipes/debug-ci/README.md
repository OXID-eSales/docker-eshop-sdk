# Install the shop from the CI container registry

## Recipe usage

1. Run ``recipes/debug-ci/run.sh``
2. Enter the buildhash of the build_oxideshop job that contains the configuration you want to investigate. You can find it in the build artifacts.

The build hash (=image tag) is stored in the ``.env`` file and can be replaced later. To do this you need to do the following steps:

1. Replace the value for ``CI_IMAGE_TAG`` in the ``.env`` file.
2. Run ``make cleanup``
3. Run ``make files``
4. Run ``make up``
5. Run ``make config``
6. Run ``make reset-shop``