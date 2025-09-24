<?php
echo "PHP Version: " . phpversion() . "\n";
echo "intl extension loaded: " . (extension_loaded('intl') ? 'YES' : 'NO') . "\n";
echo "Available extensions: \n";
$extensions = get_loaded_extensions();
foreach ($extensions as $ext) {
    if (stripos($ext, 'intl') !== false) {
        echo "- " . $ext . "\n";
    }
}
echo "Test intl functionality:\n";
try {
    $fmt = new NumberFormatter('ar', NumberFormatter::DECIMAL);
    echo "NumberFormatter created successfully\n";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?>