# UDP Simulation Script (udp_simulation.tcl)

set ns [new Simulator]                       ;# Create a new simulator instance
set nf [open udp.nam w]                      ;# Open the NAM trace file
$ns namtrace-all $nf                         ;# Trace NAM file
set tf [open out.tr w]                       ;# Open the trace file
$ns trace-all $tf                            ;# Trace all events to the trace file

# Procedure to finish simulation and close files
proc finish {} {
    global ns nf tf
    $ns flush-trace                          ;# Flush the trace file
    close $nf                                ;# Close the NAM file
    close $tf                                ;# Close the trace file
    exec nam udp.nam &                       ;# Execute the NAM animation
    exit 0                                   ;# Exit simulation
}

# Create nodes n0 to n5
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

# Create duplex links between nodes with specific bandwidth, delay, and queue type
$ns duplex-link $n0 $n4 1Mb 50ms DropTail
$ns duplex-link $n1 $n4 1Mb 50ms DropTail
$ns duplex-link $n2 $n5 0.1Mb 1ms DropTail
$ns duplex-link $n3 $n5 1Mb 1ms DropTail
$ns duplex-link $n4 $n5 1Mb 50ms DropTail

# Set the queue position for the link between n2 and n5
$ns duplex-link-op $n2 $n5 queuePos 1

# Attach a UDP agent to node n0 and a Null agent to node n2
set udp [new Agent/UDP]
$ns attach-agent $n0 $udp                    ;# Attach UDP agent to n0

set sink [new Agent/Null]
$ns attach-agent $n2 $sink                   ;# Attach Null agent (sink) to n2

# Connect the UDP agent and the Null sink
$ns connect $udp $sink

# Set up a CBR (Constant Bit Rate) application over UDP
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp                       ;# Attach CBR traffic to the UDP agent

# Schedule events: Start CBR traffic, stop CBR traffic, and finish the simulation
$ns at 0.0 "$cbr start"
$ns at 2.5 "$cbr stop"
$ns at 3.0 "finish"

# Run the simulation
$ns run
