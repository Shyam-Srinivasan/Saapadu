import React, {useState} from 'react'
import { Link , useNavigate} from 'react-router-dom';
import axios from "axios";
import {Button, Col, Container, Form, Row} from "react-bootstrap";
import {ToastContainer, toast} from "react-toastify";
import 'react-toastify/dist/ReactToastify.css';


const API_BASE = process.env.REACT_APP_API_BASE;

export const SignInPage = () => {
    const [form, setForm] = useState({
        college_name: '',
        // TODO: Other details should be added for validation
    });

    const navigate = useNavigate();

    const handleChange = (e) => {
        setForm({
           ...form,
           [e.target.name]: e.target.value
        });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();

        try{
            const res = await axios.get(
                `${API_BASE}/signIn`,
                {
                    params: {
                        collegeName: form.college_name
                    }
                });
            if(res.status === 200){
                const college = res.data;
                localStorage.setItem(
                    'college',
                    JSON.stringify(
                        {
                            id: college.college_id,
                            name: college.college_name
                        }
                    )
                );
                toast.success('Signed In Successful!', {autoClose: 2000});
                setTimeout(() => navigate('/home'), 1500);
                // navigate('/shops');
            } else {
                toast.error('No Organization Found!');
            }

        }catch (err){
            // alert(err.response?.data);
            const message = err.response?.data?.message || 'Error: Something went wrong. Please try again later.';
            toast.error(message, {autoClose: 3000});
            
        }
    };

    return(
        <Container fluid className="min-vh-100 d-flex align-items-center justify-content-center">
            <Row className="w-100 justify-content-center">
                <Col xs={12} sm={10} md={8} lg={6} xl={5}>
                    <h1 className="text-center mb-4 text-dark fs-6">SignIn to your Organization</h1>
                    <Form className='p-4 shadow rounded bg-white' onSubmit={handleSubmit}>
                        <Form.Group className="mb-3">
                          <Form.Label className='text-dark'>College Name</Form.Label>
                          <Form.Control name="college_name" type="text" value={form.college_name} onChange={handleChange} required />
                        </Form.Group>
                        <Button variant='primary' type='submit' className='w-100'>Submit</Button>
                        <p className='mt-3 text-dark'>
                            Haven't created your Organization yet? <Link to='/signUp'>Sign Up</Link>
                        </p>
                    </Form>
                </Col>
            </Row>
            <ToastContainer position="top-right"/>
        </Container>
    );
}