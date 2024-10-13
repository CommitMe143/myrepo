# TCP Simulation Script (tcp_simulation.tcl)

set ns [new Simulator]
set nf [open tcp.nam w]
$ns namtrace-all $nf
set tf [open out.tr w]
$ns trace-all $tf

proc finish {} {
    global ns nf tf
    $ns flush-trace
    close $nf
    close $tf
    exec nam tcp.nam &
    exit 0
}

# Create nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

# Create links between nodes
$ns duplex-link $n0 $n4 1Mb 50ms DropTail
$ns duplex-link $n1 $n4 1Mb 50ms DropTail
$ns duplex-link $n2 $n5 1Mb 1ms DropTail
$ns duplex-link $n3 $n5 1Mb 1ms DropTail
$ns duplex-link $n4 $n5 1Mb 50ms DropTail

# Attach TCP agent to node n0 and TCPSink to node n2
set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp

set sink [new Agent/TCPSink]
$ns attach-agent $n2 $sink

$ns connect $tcp $sink

# FTP over TCP
set ftp [new Application/FTP]
$ftp attach-agent $tcp

# Schedule events
$ns at 0.0 "$ftp start"
$ns at 2.5 "$ftp stop"
$ns at 3.0 "finish"

# Run simulation
$ns run
