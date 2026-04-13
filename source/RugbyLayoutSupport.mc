/*
 * File: RugbyLayoutSupport.mc
 * Purpose: Choose and apply the appropriate layout resource for device families/sizes.
 * Public API: static functions: applyLayout(view, dc, width, height), getLayoutId(family), getFamily(width,height)
 * Key state: stateless helper
 * Interactions: Rez.Layouts resources (resources/layouts/layout.xml), used by RugbyTimerView
 * Example usage: RugbyLayoutSupport.applyLayout(self, dc, dc.getWidth(), dc.getHeight())
 * TODOs/notes: Add unit tests for layout selection on new device profiles
 */

using Rez.Layouts;

class RugbyLayoutSupport {
    static function applyLayout(view, dc, width, height) {
        var family = RugbyLayoutSupport.getFamily(width, height);
        var layoutId = RugbyLayoutSupport.getLayoutId(family);
        if (layoutId == "MainLayoutRect") {
            view.setLayout(Rez.Layouts.MainLayoutRect(dc));
        } else if (layoutId == "MainLayoutCompactRound") {
            view.setLayout(Rez.Layouts.MainLayoutCompactRound(dc));
        } else {
            view.setLayout(Rez.Layouts.MainLayoutLargeRound(dc));
        }
        return layoutId;
    }

    static function getLayoutId(family) {
        if (family == "rect") {
            return "MainLayoutRect";
        }
        if (family == "compact_round") {
            return "MainLayoutCompactRound";
        }
        return "MainLayoutLargeRound";
    }

    static function getFamily(width, height) {
        if (width != height) {
            return "rect";
        }
        if (width <= 240) {
            return "compact_round";
        }
        return "large_round";
    }
}