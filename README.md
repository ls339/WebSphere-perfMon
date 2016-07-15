# WebSphere Performane Monitor

Perl script that fetches JVM performance data in XML format from WebSphere's perfMon servlet.
The output is formated and memory usage percentage is calculated. If the usage exceeds the
configured threshold, the error is written to an error log file.
The error log can then be monitored and configured for custom alerts.
