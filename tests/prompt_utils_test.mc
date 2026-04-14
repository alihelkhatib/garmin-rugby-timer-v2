// tests/prompt_utils_test.mc - simple smoke test for PromptUtils
import Toybox.System;
import Toybox.Json;

function main() {
    var display = {"width" => 240, "height" => 240};
    var ctx = {"contentHeight" => 150};
    var centered = PromptUtils.shouldCenterPrompt(display, ctx);
    System.println("TEST|prompt_utils|shouldCenterPrompt result=" + (centered ? "true" : "false"));
    var bounds = PromptUtils.computeCenteredBounds(display, {"width" => 200, "height" => 150});
    System.println("TEST|prompt_utils|bounds=" + Json.toString(bounds));
}
