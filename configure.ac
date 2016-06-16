AC_INIT(geogrid, 3.3.5, alex.deckmyn@meteo.be)
AC_CONFIG_SRCDIR(src/geogrid.c)

# find R home and set correct compiler + flags
: ${R_HOME=`R RHOME`}
if test -z "${R_HOME}"; then
  AC_MSG_ERROR([cannot determine R_HOME. Make sure you use R CMD INSTALL!])
fi
RBIN="${R_HOME}/bin/R"

# pick all flags for testing from R
: ${CC=`"${RBIN}" CMD config CC`}
: ${CPP=`"${RBIN}" CMD config CPP`}
: ${CFLAGS=`"${RBIN}" CMD config CFLAGS`}
: ${CPPFLAGS=`"${RBIN}" CMD config CPPFLAGS`}
: ${LDFLAGS=`"${RBIN}" CMD config LDFLAGS`}

# honor PKG_xx overrides
LIBS="${LIBS} ${PKG_LIBS}"
# for CPPFLAGS we will superfluously double R's flags
# since we'll set PKG_CPPFLAGS with this, but that shouldn't hurt
CPPFLAGS="${CPPFLAGS} ${PKG_CPPFLAGS}"

proj4ok=yes
AC_CHECK_HEADERS(proj_api.h,,proj4ok=no)
if test "${proj4ok}" = no; then
   AC_MSG_ERROR([proj_api.h not found.
*** Install PROJ.4 and if necessary set PKG_CPPFLAGS/PKG_LIBS accordingly.])
fi
AC_CHECK_LIB(proj,pj_init,,proj4ok=no)
if test "${proj4ok}" = no; then
   AC_MSG_ERROR([libproj not found.
*** Install PROJ.4 and if necessary set PKG_CPPFLAGS/PKG_LIBS accordingly.])
fi

AC_ARG_VAR([PKG_CPPFLAGS],[custom C preprocessor flags for packages compilation])
AC_ARG_VAR([PKG_LIBS],[custom libraries for package compilation])

AC_CONFIG_FILES(src/Makevars)
AC_OUTPUT


