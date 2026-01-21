{
  lib,
  gtsam,
  python3,
  toPythonModule,
}:

toPythonModule (
  gtsam.override {
    enablePython = true;
    inherit python3;
  }
)
