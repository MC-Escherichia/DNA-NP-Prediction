echo off
"$JAVA_HOME\bin\java" -Xmx512m -cp "$INSTALL_PATH\Systre.jar" org.gavrog.apps.systre.SystreCmdline %*
