function sessionConf = updateNasPath(sessionConf)

sessionConf.nasPath = sqlv2_findNASpath(sessionConf.subjects__name);