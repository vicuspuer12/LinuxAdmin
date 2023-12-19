[finalPdf.pdf](https://github.com/vicuspuer12/LinuxAdmin/files/13712436/finalPdf.pdf)
Use Case:
Enrich Slack notifications with Wazuh FIM and vulnerability alert details.

Painless scripts (Mustache templates):
Wazuh File Integrity Monitoring alerts information:

  Wazuh File Integrity Monitoring
    
        {{#ctx.results.0.hits.hits}}
        - Index: {{_index}}
        - Document: {{_id}} 
        - Alert Description : {{_source.rule.description}} 
        - Alert id : {{_source.rule.id}}
        - FIM path : {{_source.syscheck.path}}
        - FIM event: {{_source.syscheck.event}}
        - Alert Timestamp : {{_source.@timestamp}}
        {{/ctx.results.0.hits.hits}}

Wazuh Vulnerability alerts information:

  Wazuh Vulnerability
    
        {{#ctx.results.0.hits.hits}}
        - Index: {{_index}}
        - Document: {{_id}} 
        - Alert Description : {{_source.rule.description}} 
        - Alert id : {{_source.rule.id}}
        - Vulnerability Severity: {{_source.data.vulnerability.severity}}
        - Vulnerability CVE: {{_source.data.vulnerability.cve}}
        - Alert Timestamp : {{_source.@timestamp}}
        {{/ctx.results.0.hits.hits}}

Opensearch/Wazuh Monitor Queries:

  FIM:

        {
            "query": {
            "bool": {
              "must": [],
              "filter": [
                {
                  "match_all": {}
                },
                {
                  "match_phrase": {
                    "rule.groups": "syscheck"
                  }
                },
                {
                  "range": {
                    "timestamp": {
                      "gt": "now-5m",
                      "lte": "now",
                      "format": "strict_date_optional_time"
                    }
                  }
                }
              ]
            }
            }
        }

Vulnerability:

        {
            "query": {
            "bool": {
              "must": [],
              "filter": [
                {
                  "match_all": {}
                },
                {
                  "match_phrase": {
                    "rule.groups": "vulnerability-detector"
                  }
                },
                {
                  "range": {
                    "timestamp": {
                      "gt": "now-5m",
                      "lte": "now",
                      "format": "strict_date_optional_time"
                    }
                  }
                }
              ]
            }
            }
        }


