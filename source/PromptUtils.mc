/*
 * File: PromptUtils.mc
 * Purpose: Helper heuristics for centering prompts on round screens.
 * Public API: PromptUtils.shouldCenterPrompt(displayInfo, promptContext),
 *             PromptUtils.computeCenteredBounds(displayInfo, contentSize)
 * Note: Lightweight heuristics only; resource-first approach preferred.
 */

import Toybox.System;
import Toybox.Lang;

class PromptUtils {

    function initialize() {
    }

    function shouldCenterPrompt(displayInfo as Dictionary, promptContext as Dictionary) as Boolean {
        if (displayInfo == null) {
            return false;
        }
        var w = displayInfo["width"] == null ? 0 : displayInfo["width"];
        var h = displayInfo["height"] == null ? 0 : displayInfo["height"];
        // Heuristic: prefer centering on square displays (round) or tall prompts
        if (w == h && w > 0) {
            return true;
        }
        // If content height would exceed ~60% of screen height, center to avoid clipping
        if (promptContext != null && promptContext["contentHeight"] != null) {
            var ch = promptContext["contentHeight"];
            if (ch > (h * 0.6)) {
                return true;
            }
        }
        return false;
    }

    function computeCenteredBounds(displayInfo as Dictionary, contentSize as Dictionary) as Dictionary {
        var w = displayInfo["width"] == null ? 0 : displayInfo["width"];
        var h = displayInfo["height"] == null ? 0 : displayInfo["height"];
        var cw = contentSize["width"] == null ? w : contentSize["width"];
        var ch = contentSize["height"] == null ? h : contentSize["height"];
        var x = (w - cw) / 2;
        var y = (h - ch) / 2;
        if (x < 0) x = 0;
        if (y < 0) y = 0;
        return {"x" => x, "y" => y, "width" => cw, "height" => ch};
    }
}

var PromptUtils = new PromptUtils();
