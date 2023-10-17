from fastapi import FastAPI, Request, Form
from fastapi.templating import Jinja2Templates

app = FastAPI()
templates = Jinja2Templates(directory="templates")  # Create a templates directory for HTML templates

# Create a simple HTML form

@app.get("/")
async def read_root(request: Request):
    return templates.TemplateResponse("form.html", {"request": request})

@app.post("/")
async def write_dates(request: Request, name:str=Form(...), start_date: str = Form(...), end_date: str = Form(...)):
    with open("dates.txt", "a") as file:
        file.write(f"{name}|{start_date}|{end_date}\n")
    return templates.TemplateResponse("form.html", {"request": request})

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
