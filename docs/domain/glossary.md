# Domain glossary

## Model summary

A read-only DTO describing the active Revit document: title, path, version, element count and category counts.

## AI Gateway

Out-of-process service that receives structured model summaries and returns AI-generated analysis, recommendations or next steps.

## MCP tool

A narrowly scoped callable capability exposed to an AI client through Model Context Protocol.

## Revit bridge

Local IPC boundary between MCP server and the running Revit add-in.

## Valid Revit API context

A call stack entered by Revit, such as external commands, application callbacks, events, updaters or ExternalEvent handlers.
