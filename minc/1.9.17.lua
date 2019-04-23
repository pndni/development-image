-- from minc-toolkit-config.sh
-- dropped LD_LIBRARY_PATH because everything should be
-- statically linked
-- to confirm, set LD_LIBRARY_PATH as below and run "for i in `ls`; do ldd $i | grep -i minc; done" in bin
-- it should yield no results
local root="/opt/minc"
conflict("freesurfer")
setenv("MINC_TOOLKIT", root)
setenv("MINC_TOOLKIT_VERSION", "1.9.17-20190313")
prepend_path("PATH", pathJoin(root, "pipeline"))
prepend_path("PATH", pathJoin(root, "bin"))
prepend_path("PERL5LIB", pathJoin(root, "pipeline"))
prepend_path("PERL5LIB", pathJoin(root, "perl"))
-- export LD_LIBRARY_PATH=${MINC_TOOLKIT}/lib:${MINC_TOOLKIT}/lib/InsightToolkit:${LD_LIBRARY_PATH}
setenv("MNI_DATAPATH", pathJoin(root, "..", "share")) -- this doens't point to anything, should raise an issue
setenv("MINC_FORCE_V2", "1")
setenv("MINC_COMPRESS", "4")
setenv("VOLUME_CACHE_THRESHOLD", "-1")
