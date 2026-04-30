proc user_explain_cts_cell {cell} {

    # ---- extract creator tag ----
    # CTS_<creator>_...
    set creator ""

    if {[regexp {CTS_([^_]+)} $cell -> creator]} {
        # ok
    } else {
        return "No CTS creator tag found"
    }

    # ---- creator map ----
    array set map {

        CTSG      "Deprecated creator (should not be used)"
        cuk       "Unknown creator (internal)"
        ccl_a     "Clustering (agglomerative)"
        cbi       "Power optimization swap"
        cex       "Existing cell kept"
        coi       "Inversion cancellation"
        lbl       "Clustering for slew target"
        ccl       "Clustering for slew target"
        ccd       "Clustering for balancing"
        cci       "Clustering inversion fix"
        csf       "Slew fixing (CTS)"
        cms       "Clock gate move (enable timing)"
        cid       "Weak driver buffering"
        cdb       "Delay balancing"
        cdbw      "Delay balancing"
        cwb       "Wire delay balancing"
        cfo       "Fanout skew reduction"
        csk       "Fine skew fixing"
        cmf       "Long net buffering"
        cbc       "Subtree cloning (conditioning)"
        css       "Early sink cloning"
        cdc       "Added driver cell"
        cpd       "Port driver insertion"
        ccg       "Clock gate synthesis"
        cse       "Exclude pin driver"
        cfh       "H-tree driver"
        cat       "Clock source group root"
        cpc_drv   "Post conditioning driver"
        cpc_sk    "Post conditioning skew"
        PRO       "Post-route optimization"
        PRO_drv   "Post-route driver"
        PRO_sk    "Post-route skew"
        sfc       "Slew fixing clone"
        ccc       "clone_clock_cells command"
        grb       "Global route buffering"
        sgb       "Source group balancing"
        idc       "Insertion delay reduction clone"
        vgb       "VG buffering"
        USK       "Skew clock optimization"
        cff       "Fanout fixing"
        cng       "Polarity correction inverter"
        incr      "Incremental CTS"
        cgp       "Clock gate push-up"
        usf_dcls_sn   "USF DCLS split net"
        usf_dcls_snw  "USF DCLS split network"
        usf_tmr_sn    "USF TMR split net"
        usf_tmr_snw   "USF TMR split network"
        usf_pc        "USF polarity correction"
    }

    if {[info exists map($creator)]} {
        return "$creator -> $map($creator)"
    }

    return "$creator -> Unknown creator"
}
