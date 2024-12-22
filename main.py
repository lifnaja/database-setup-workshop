from fastapi import FastAPI, Form, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from psycopg2 import connect

import duckdb

app = FastAPI()
templates = Jinja2Templates(directory="templates")


@app.get("/hello")
async def root():
    return {"message": "Hello World"}

@app.get("/", response_class=HTMLResponse)
async def get_form(request: Request):
    return templates.TemplateResponse("form.html", {"request": request})


def read_sql_script(file_path: str) -> str:
    with open(file_path, "r", encoding="utf-8") as file:
        return file.read()

@app.post("/submit", response_class=HTMLResponse)
async def submit_form(
    request: Request,
    host: str = Form(...),
    port: str = Form(...),
    dbname: str = Form(...),
    user: str = Form(...),
    password: str = Form(...),
):
    try:
        with connect(
            host=host,
            port=port,
            dbname=dbname,
            user=user,
            password=password,
        ) as conn, conn.cursor() as cursor:
        
            cursor.execute(read_sql_script('data/_ddl.sql'))
            conn.commit()
            print(f"{host} :: created table success")

            cursor.execute(read_sql_script('data/aircrafts_data.sql'))
            conn.commit()
            print(f"{host} :: inserted aircrafts data success")

            cursor.execute(read_sql_script('data/airports_data.sql'))
            conn.commit()
            print(f"{host} :: inserted airports data success")

        with duckdb.connect() as dc:
            dc.execute('INSTALL postgres;LOAD postgres;')
            dc.execute(f"""
                CREATE SECRET postgres_secret_con(
                    TYPE POSTGRES,
                    HOST '{host}',
                    PORT '{port}',
                    DATABASE '{dbname}',
                    USER '{user}',
                    PASSWORD '{password}'
                );
            """)
            dc.execute(f""" 
                ATTACH '' AS postgres_db (TYPE POSTGRES, SECRET postgres_secret_con);

                COPY postgres_db.boarding_passes FROM 'data/boarding_passes.csv';
                COPY postgres_db.bookings FROM 'data/bookings.csv';
                COPY postgres_db.flights FROM 'data/flights.csv';
                COPY postgres_db.seats FROM 'data/seats.csv';
                COPY postgres_db.ticket_flights FROM 'data/ticket_flights.csv';
                COPY postgres_db.tickets FROM 'data/tickets.csv';
            """)  # noqa: F541

            conn.commit()


        return templates.TemplateResponse(
            "result.html", {"request": request, "message": "Table created and data inserted successfully!"}
        )

    except Exception as e:
        print(e)
        return templates.TemplateResponse(
            "result.html", {"request": request, "message": f"Database connection failed: {e}"}
        )
