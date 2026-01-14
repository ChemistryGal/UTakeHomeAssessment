import configparser

def load_config():
    cfg = configparser.ConfigParser()
    cfg.read("config.ini")

    sql = cfg["sqlserver"]
    data = cfg["data"]

    return {
        "sql": {
            "server": sql.get("server"),
            "database": sql.get("database"),
            "driver": sql.get("driver"),
            "trusted": sql.getboolean("trusted_connection", True),
        },
        "data": {
            "csv_path": data.get("csv_path"),
            "delimiter": data.get("csv_delimiter", ","),
            "encoding": data.get("csv_encoding", "utf-8"),
            "batch_size": data.getint("batch_size", 50000),
        }
    }
