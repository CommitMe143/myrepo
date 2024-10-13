# Distance Vector Routing Protocol Simulation with Link Failure

# Step 1: Create a simulator object
set ns [new Simulator]

# Step 2: Set routing protocol to Distance Vector routing
$ns rtproto DV

# Step 3: Open NAM and trace files
set nf [open out.nam w]                        ;# NAM trace file
$ns namtrace-all $nf                           ;# NAM trace
set nt [open trace.tr w]                       ;# Text trace file
$ns trace-all $nt                              ;# Trace all events

# Step 4: Define a finish procedure to close files and run NAM
proc finish {} {
    global ns nf nt
    $ns flush-trace                            ;# Flush trace file
    close $nf                                  ;# Close NAM file
    close $nt                                  ;# Close trace file
    exec nam out.nam &                         ;# Execute NAM for visual output
    exit 0                                     ;# Exit the simulation
}

# Step 5: Create eight nodes (n1 to n8)
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]

# Step 6: Specify the link characteristics between nodes
$ns duplex-link $n1 $n2 1Mb 10ms DropTail     ;# Link between n1 and n2
$ns duplex-link $n2 $n3 1Mb 10ms DropTail     ;# Link between n2 and n3
$ns duplex-link $n3 $n4 1Mb 10ms DropTail     ;# Link between n3 and n4
$ns duplex-link $n4 $n5 1Mb 10ms DropTail     ;# Link between n4 and n5
$ns duplex-link $n5 $n6 1Mb 10ms DropTail     ;# Link between n5 and n6
$ns duplex-link $n6 $n7 1Mb 10ms DropTail     ;# Link between n6 and n7
$ns duplex-link $n7 $n8 1Mb 10ms DropTail     ;# Link between n7 and n8
$ns duplex-link $n8 $n1 1Mb 10ms DropTail     ;# Link between n8 and n1

# Step 7: Describe their layout topology as an octagon
$ns duplex-link-op $n1 $n2 orient left-up
$ns duplex-link-op $n2 $n3 orient up
$ns duplex-link-op $n3 $n4 orient right-up
$ns duplex-link-op $n4 $n5 orient right
$ns duplex-link-op $n5 $n6 orient right-down
$ns duplex-link-op $n6 $n7 orient down
$ns duplex-link-op $n7 $n8 orient left-down
$ns duplex-link-op $n8 $n1 orient left

# Step 8: Add UDP agent to node n1
set udp0 [new Agent/UDP]
$ns attach-agent $n1 $udp0

# Step 9: Create CBR traffic on top of UDP and set traffic parameters
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500                      ;# Set packet size
$cbr0 set interval_ 0.005                      ;# Set traffic interval
$cbr0 attach-agent $udp0

# Step 10: Add a null agent (sink) to node n4
set null0 [new Agent/Null]
$ns attach-agent $n4 $null0

# Step 9: Connect source (n1) and sink (n4)
$ns connect $udp0 $null0

# Label source and destination nodes
$ns at 0.0 "$n1 label Source"
$ns at 0.0 "$n4 label Destination"

# Step 10: Schedule events
$ns at 0.5 "$cbr0 start"                       ;# Start CBR traffic at 0.5 seconds
$ns rtmodel-at 1.0 down $n3 $n4                ;# Bring down the link between n3 and n4 at 1.0 seconds
$ns rtmodel-at 2.0 up $n3 $n4                  ;# Bring the link back up at 2.0 seconds
$ns at 4.5 "$cbr0 stop"                        ;# Stop CBR traffic at 4.5 seconds
$ns at 5.0 "finish"                            ;# Call finish procedure at 5.0 seconds

# Step 11: Run the simulation
$ns run
