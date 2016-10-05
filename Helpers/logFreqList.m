function freqList = logFreqList(fpass,n)

freqList = exp(linspace(log(fpass(1)),log(fpass(2)),n));