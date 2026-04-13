import Toybox.Application;

const RUGBY_VARIANT_FIFTEENS = "fifteens";
const RUGBY_VARIANT_SEVENS = "sevens";
const RUGBY_VARIANT_TENS = "tens";
const RUGBY_VARIANT_U19 = "u19";
const RUGBY_VARIANT_CUSTOM = "custom";
const RUGBY_DEFAULT_VARIANT = RUGBY_VARIANT_FIFTEENS;

class RugbyVariantConfig {

    static function presets() {
        return {
            RUGBY_VARIANT_FIFTEENS => {
                "id" => RUGBY_VARIANT_FIFTEENS,
                "name" => "15s",
                "halfLengthSeconds" => 2400,
                "halfCount" => 2,
                "sinBinLengthSeconds" => 600,
                "conversionLengthSeconds" => 90
            },
            RUGBY_VARIANT_SEVENS => {
                "id" => RUGBY_VARIANT_SEVENS,
                "name" => "7s",
                "halfLengthSeconds" => 420,
                "halfCount" => 2,
                "sinBinLengthSeconds" => 120,
                "conversionLengthSeconds" => 30
            },
            RUGBY_VARIANT_TENS => {
                "id" => RUGBY_VARIANT_TENS,
                "name" => "10s",
                "halfLengthSeconds" => 600,
                "halfCount" => 2,
                "sinBinLengthSeconds" => 300,
                "conversionLengthSeconds" => 60
            },
            RUGBY_VARIANT_U19 => {
                "id" => RUGBY_VARIANT_U19,
                "name" => "U19",
                "halfLengthSeconds" => 2100,
                "halfCount" => 2,
                "sinBinLengthSeconds" => 480,
                "conversionLengthSeconds" => 90
            }
        };
    }

    static function defaultSetup(variantId) {
        var allPresets = presets();
        var preset = allPresets[variantId];
        if (preset == null) {
            preset = allPresets[RUGBY_DEFAULT_VARIANT];
        }

        return {
            "variantId" => preset["id"],
            "variantName" => preset["name"],
            "halfLengthSeconds" => preset["halfLengthSeconds"],
            "halfCount" => preset["halfCount"],
            "sinBinLengthSeconds" => preset["sinBinLengthSeconds"],
            "conversionLengthSeconds" => preset["conversionLengthSeconds"],
            "homeLabel" => "Home",
            "awayLabel" => "Away"
        };
    }

    static function applyOverrides(setup, halfDeltaMinutes, sinBinSeconds, conversionSeconds) {
        var updated = cloneSetup(setup);
        if (halfDeltaMinutes != 0) {
            var nextHalf = updated["halfLengthSeconds"] + (halfDeltaMinutes * 60);
            updated["halfLengthSeconds"] = clamp(nextHalf, 60, 3600);
            updated["variantId"] = RUGBY_VARIANT_CUSTOM;
            updated["variantName"] = "Custom";
        }
        if (sinBinSeconds != null) {
            updated["sinBinLengthSeconds"] = clamp(sinBinSeconds, 60, 1200);
            updated["variantId"] = RUGBY_VARIANT_CUSTOM;
            updated["variantName"] = "Custom";
        }
        if (conversionSeconds != null) {
            updated["conversionLengthSeconds"] = clamp(conversionSeconds, 15, 300);
            updated["variantId"] = RUGBY_VARIANT_CUSTOM;
            updated["variantName"] = "Custom";
        }
        return updated;
    }

    static function adjustHalfMinutes(setup, deltaMinutes) {
        return applyOverrides(setup, deltaMinutes, null, null);
    }

    static function withSinBinSeconds(setup, seconds) {
        return applyOverrides(setup, 0, seconds, null);
    }

    static function withConversionSeconds(setup, seconds) {
        return applyOverrides(setup, 0, null, seconds);
    }

    static function cloneSetup(setup) {
        return {
            "variantId" => setup["variantId"],
            "variantName" => setup["variantName"],
            "halfLengthSeconds" => setup["halfLengthSeconds"],
            "halfCount" => setup["halfCount"],
            "sinBinLengthSeconds" => setup["sinBinLengthSeconds"],
            "conversionLengthSeconds" => setup["conversionLengthSeconds"],
            "homeLabel" => setup["homeLabel"],
            "awayLabel" => setup["awayLabel"]
        };
    }

    static function savePreferences(setup) {
        // Preference persistence is intentionally disabled until the app property
        // store is wired with the correct Connect IQ API shape for this project.
    }

    static function loadPreferences() {
        return defaultSetup(RUGBY_DEFAULT_VARIANT);
    }

    static function clamp(value, minValue, maxValue) {
        if (value < minValue) {
            return minValue;
        }
        if (value > maxValue) {
            return maxValue;
        }
        return value;
    }
}





