/*
 * File: RugbyActivityExporter.mc
 * Purpose: Small adapter to translate Event[] into ActivityRecording-friendly records and attach them to a session.
 * This is intentionally minimal and non-blocking; the higher-level recorder manages retries.
 */

import Toybox.System;
import Toybox.Lang;
import Toybox.ActivityRecording;

const RUGBY_EXPORT_MAX_RETRIES = 3;
const RUGBY_EXPORT_BACKOFFS = [2000, 5000, 10000];

class RugbyActivityExporter {

    function initialize() {
    }

    // Translate Event[] to an array of string records suitable for appendRecords/addComment
    function eventsToRecords(events as Array<Dictionary>) as Array<String> {
        var recs = [] as Array<String>;
        if (events == null) {
            return recs;
        }
        var i = 0;
        while (i < events.size()) {
            var e = events[i] as Dictionary;
            var ts = e["timestamp"] == null ? "" : ("" + e["timestamp"]);
            var t = e["type"] == null ? "" : e["type"];
            var a = e["actor"] == null ? "" : e["actor"];
            var v = e["value"] == null ? "" : ("" + e["value"]);
            var d = e["details"] == null ? "" : e["details"];
            var s = t + "|" + ts + "|" + a + "|" + v + "|" + d;
            recs.add(s);
            i = i + 1;
        }
        return recs;
    }

    // Attach records to a session using the best available API; returns true on success
    function attachEvents(session, events as Array<Dictionary>) as Boolean {
        if (session == null) {
            return false;
        }
        var recs = eventsToRecords(events);
        try {
            if (session has :appendRecords) {
                session.appendRecords(recs);
                return true;
            } else if (session has :addEvent) {
                var j = 0;
                while (j < events.size()) {
                    var ev = events[j];
                    session.addEvent(ev["type"], ev["timestamp"], ev["actor"], ev["value"], ev["details"]);
                    j = j + 1;
                }
                return true;
            } else if (session has :addComment) {
                var k = 0;
                while (k < recs.size()) {
                    session.addComment(recs[k]);
                    k = k + 1;
                }
                return true;
            } else if (session has :addMarker) {
                var m = 0;
                while (m < recs.size()) {
                    session.addMarker(recs[m]);
                    m = m + 1;
                }
                return true;
            }
        } catch (ex) {
            System.println("RUGBY|RugbyActivityExporter|attachEvents failed ex=" + ex.toString());
            return false;
        }
        return false;
    }
}

var RugbyActivityExporter = new RugbyActivityExporter();
