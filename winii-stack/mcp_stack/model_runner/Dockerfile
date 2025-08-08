FROM python:3.10-slim
WORKDIR /app
COPY model/ /app/model
RUN pip install streamlit
EXPOSE 8501
CMD ["streamlit", "run", "/app/model/main.py"]
