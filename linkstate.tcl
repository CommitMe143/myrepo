# Link-State Routing Protocol Simulation with Link Failure

# Step 1: Create a simulator object
set ns [new Simulator]

# Step 2: Open NAM and trace files
set nf [open out.nam w]                        ;# NAM trace file
$ns namtrace-all $nf                           ;# NAM trace
set tr [open out.tr w]                         ;# Text trace file
$ns trace-all $tr                              ;# Trace all events

# Step 4: Define a finish procedure to close files and run NAM
proc finish {} {
    global ns nf tr
    $ns flush-trace                            ;# Flush trace file
    close $nf                                  ;# Close NAM file
    close $tr                                  ;# Close trace file
    exec nam out.nam &                         ;# Execute NAM for visual output
    exit 0                                     ;# Exit the simulation
}

# Step 5: Create four nodes (n0, n1, n2, n3)
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

# Step 6: Specify the link characteristics between nodes
$ns duplex-link $n0 $n1 10Mb 10ms DropTail     ;# Link between n0 and n1
$ns duplex-link $n1 $n3 10Mb 10ms DropTail     ;# Link between n1 and n3
$ns duplex-link $n2 $n1 10Mb 10ms DropTail     ;# Link between n2 and n1

# Step 7: Describe their layout topology
$ns duplex-link-op $n0 $n1 orient right-down
$ns duplex-link-op $n1 $n3 orient right
$ns duplex-link-op $n2 $n1 orient right-up

# Step 8: Add TCP agent to node n0
set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp

# Step 9: Create FTP traffic on top of TCP and set traffic parameters
set ftp [new Application/FTP]
$ftp attach-agent $tcp

# Step 10: Add a sink agent to node n3
set sink [new Agent/TCPSink]
$ns attach-agent $n3 $sink

# Step 11: Add UDP agent to node n2
set udp [new Agent/UDP]
$ns attach-agent $n2 $udp

# Step 12: Create CBR traffic on top of UDP and set traffic parameters
set cbr [new Application/Traffic/CBR]
$cbr set rate_ 1Mb                             ;# Set the rate for CBR
$cbr attach-agent $udp

# Set null agent to act as the sink for UDP traffic
set null [new Agent/Null]
$ns attach-agent $n3 $null

# Step 13: Connect TCP and UDP agents to their respective sinks
$ns connect $tcp $sink
$ns connect $udp $null

# Step 14: Schedule events
$ns at 0.0 "$ftp start"                        ;# Start FTP traffic at 0.0
$ns at 0.0 "$cbr start"                        ;# Start CBR traffic at 0.0
$ns rtmodel-at 1.0 down $n1 $n3                ;# Bring down the link between n1 and n3 at 1.0
$ns rtmodel-at 2.0 up $n1 $n3                  ;# Bring the link back up at 2.0
$ns at 5.0 "finish"                            ;# Call finish procedure at 5.0

# Step 2: Set the routing protocol to link-state routing
$ns rtproto LS

# Step 15: Run the simulation
$ns run
