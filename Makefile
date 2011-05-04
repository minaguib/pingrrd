WIDTH?=900
HEIGHT?=300
END?=now
RRA?=AVERAGE
IP:=$(shell cat IP)
NOW:=$(shell date)

graphs: graph-1minute graph-1hour graph-1day graph-1week graph-1month graph-3month graph-6month

graph-1minute: RRA = LAST

graph-%: data/ping.rrd
	rrdtool graph --width ${WIDTH} --height ${HEIGHT} \
	--start end-$* --end "${END}" \
	--title "PING TO ${IP} - RTT & loss - ($*)" \
	--vertical-label "PING RTT (+ms) and packet loss (-%)" \
	--watermark "${NOW}" \
	\
	graphs/$*.png \
	\
	DEF:sent=data/ping.rrd:sent:${RRA} \
	DEF:received=data/ping.rrd:received:${RRA} \
	DEF:lost=data/ping.rrd:lost:${RRA} \
	DEF:rtt=data/ping.rrd:rtt:${RRA} \
	\
	CDEF:rtt-low=rtt,0,ADDNAN,20,LE,rtt,20,IF \
	CDEF:rtt-medium=rtt,20,GT,rtt,60,GT,40,rtt,20,-,IF,UNKN,IF \
	CDEF:rtt-high=rtt,60,GT,rtt,120,GT,60,rtt,60,-,IF,UNKN,IF \
	CDEF:rtt-crit=rtt,120,GT,rtt,120,-,UNKN,IF \
	CDEF:packetloss=lost,sent,/,100,* \
	CDEF:npacketloss=packetloss,-1,* \
	\
	AREA:rtt-low#ddff3399::STACK \
	AREA:rtt-medium#ffcc3399::STACK \
	AREA:rtt-high#ff663399::STACK \
	AREA:rtt-crit#66000099::STACK \
	\
	COMMENT:" \n" \
	\
	GPRINT:rtt:LAST:"   PING RTT current (%7.2lfms) " \
	GPRINT:rtt:AVERAGE:" avg (%7.2lfms)" \
	GPRINT:rtt:MIN:" min (%7.2lfms)" \
	GPRINT:rtt:MAX:" max (%7.2lfms)\n" \
	\
	HRULE:0#a0a0a0 \
	\
	AREA:npacketloss#660000 \
	\
	GPRINT:packetloss:LAST:"Packet loss current (%6.2lf%%) " \
	GPRINT:packetloss:AVERAGE:"   avg (%6.2lf%%)" \
	GPRINT:packetloss:MIN:"   min (%6.2lf%%)" \
	GPRINT:packetloss:MAX:"   max (%6.2lf%%)\n" \
	COMMENT:" \n"

data/ping.rrd:
# 10-second points - keep 1 month (60/10 * 60 * 24 * 30)
# 1-minute averages - keep 1 month (60 * 24 * 30)
# 1-hour averages - keep 1 year (24 * 365)
	rrdtool create data/ping.rrd \
	\
	--step 10 \
	\
	DS:sent:GAUGE:30:0:U \
	DS:received:GAUGE:30:0:U \
	DS:lost:GAUGE:30:0:U \
	DS:rtt:GAUGE:30:0:U \
	\
	RRA:LAST:0.5:1:259200 \
	\
	RRA:AVERAGE:0.5:6:43200 \
	RRA:AVERAGE:0.5:360:8760 \
	\
	RRA:MAX:0.5:6:43200 \
	RRA:MAX:0.5:360:8760

clean:
	-rm data/ping.rrd
	-rm graphs/*.png
