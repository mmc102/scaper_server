from fastapi import FastAPI, Request, Form
from fastapi.responses import RedirectResponse
from fastapi.templating import Jinja2Templates

app = FastAPI()
templates = Jinja2Templates(directory="templates")  # Create a templates directory for HTML templates

# Create a simple HTML form

@app.get("/")
async def read_root(request: Request):
    with open("dates.txt", "r") as file:
        lines = file.readlines()
    return templates.TemplateResponse("form.html", {"request": request, "lines":lines})

@app.post("/add")
async def write_dates(request: Request, name:str=Form(...), start_date: str = Form(...), end_date: str = Form(...)):
    with open("dates.txt", "a") as file:
        file.write(f"{name}|{start_date}|{end_date}|Null|Null\n")

    return templates.TemplateResponse("form.html", {"request": request})

@app.post("/remove")
async def remove_line(request:Request,line: str= Form(...)):
    # Remove the line from the list
    with open("dates.txt", "r") as file:
        lines = file.readlines()
    try:
        lines.remove(line.replace('\r',""))
    except ValueError:
        pass

    with open("kill.txt", "w") as file:
        _name, _start, _end, container_id, _status = line.split("|")
        file.write(container_id)
    # Update the file with the new lines
    with open("dates.txt", "w") as file:
        file.writelines(lines)


    return templates.TemplateResponse("form.html", {"request": request})


# TODO add tracking on docker PID and kill when the job is over
# TODO group by
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
