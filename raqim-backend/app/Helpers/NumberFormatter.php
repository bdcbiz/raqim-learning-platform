<?php

if (!class_exists('NumberFormatter') && !extension_loaded('intl')) {
    class NumberFormatter
    {
        const DECIMAL = 1;

        private $locale;
        private $style;

        public function __construct($locale, $style)
        {
            $this->locale = $locale;
            $this->style = $style;
        }

        public function format($number)
        {
            return number_format((float)$number, 2);
        }
    }
}