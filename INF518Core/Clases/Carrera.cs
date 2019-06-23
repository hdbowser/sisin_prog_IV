﻿using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace INF518Core.Clases
{
    public class Carrera : MantenimientoBase
    {

        public Carrera()
        {

        }

        public int ID { get; set; }
        public string Descripcion { get; set; }
        public string Observaciones { get; set; }
        public int Credito { get; set; }

        public DataTable Listado()
        {
            //SqlCommand cmd = new SqlCommand();

            Command.CommandType = CommandType.StoredProcedure;
            Command.CommandText = "sp_ListadoCarrera";
            Command.CommandTimeout = 0;

            DataTable dt = new DataTable();
            Adapter = new SqlDataAdapter(Command);
            try
            {
                Connection.Open();
                Adapter.Fill(dt); //se asigna todo al datatable
            }
            catch (Exception ex)
            {
                throw ex; //esto es temporal
            }
            finally
            {
                Connection.Close();
            }
            return dt;
        }
    }


}
